%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Universidade Federal de Sao Carlos - UFSCar, Sorocaba
%
%  Disciplina: Aprendizado de Maquina
%  Prof. Tiago A. Almeida
%
%  Loan Default Prediction - Imperial College London
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inicializacao
clear; close all; clc;

GRID_SEARCH = {};

try
  matlabpool;
catch
  try
    parpool;
  catch
    fprintf('Nao foi encontrado nenhum metodo para computacao paralela (ou ja esta rodando)\n\n');
  end
end

%% Carrega scripts
addpath('./feature_selection');
addpath('./model_selection');
addpath('./util');
addpath('./grid');
addpath('./algs/knn');
addpath('./algs/reglin');
addpath('./algs/reglog');
addpath('./algs/pca');
addpath('./algs/bayes');
addpath('./algs/svm');
addpath('./algs/ann');

%% Carrega os dados do arquivo
fprintf('Carregando os dados...\n\n');

[df, losses] = importfile('train_v2.mat', 1);

ptm(df);

% Realiza operacoes nas features e observacoes
[dfx, losses, modifiers] = analise(df, losses, 241);

clear df;

% Inicializa variaveis uteis

gs = struct;

losses_logical = losses > 0;

losses_bool = double(losses_logical);
dfx_loss = dfx(losses_logical, :);
losses_loss = losses(losses_logical);

% Aleatoriza amostras

perm = randperm(size(dfx, 1));
dfx = dfx(perm, :);
losses_bool = losses_bool(perm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRID SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gs = do_grid_search(dfx, losses, GRID_SEARCH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLASSIFICADORES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_method('kNN', ...
  dfx, losses_bool, @apply_knn, @knn_error, false, gs.kNN);

run_method('Regressao logistica', ...
  dfx, losses_bool, @apply_reglog, @reglog_error, false, gs.reglog);

run_method('Naive Bayes', ...
  dfx, losses_bool, @apply_bayes, @bayes_error, false);

modelSVM = run_method('SVM', ...
  dfx, losses_bool, @apply_svm, @svm_error, false, gs.svm);

% hidden layers, neurons, outputs, lambda
run_method('Redes Neurais artificiais', ...
  dfx, losses_bool, @apply_ann, @ann_error, false, 1, 5, 2, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REGRESSORES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modelRegLin = run_method('Regressao linear', ...
  dfx_loss, losses_loss, @apply_reglin, @reglin_error, false, gs.reglin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SALVA DADOS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Salvando os dados...\n\n');

models = struct;
models.classificador = modelSVM{:};
models.regressor = modelRegLin{:};

save('loan-predict.mat', 'modifiers', 'models');
