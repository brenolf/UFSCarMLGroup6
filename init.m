%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Universidade Federal de Sao Carlos - UFSCar, Sorocaba
%
%  Disciplina: Aprendizado de Maquina
%  Prof. Tiago A. Almeida
%
%  Loan Default Prediction - Imperial College London
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inicializacao
clear ; close all; clc;

GRID_SEARCH = true;

%% Carrega funcoes de selecao de atributos
addpath('./feature_selection');
addpath('./model_selection');
addpath('./util');
addpath('./algs/knn');
addpath('./algs/reglog');

%% Carrega os dados do arquivo
fprintf('Carregando os dados...\n\n');

[df, losses] = importfile('train_v2.csv', 2, 100);

ptm(df);

% Limpeza inicial
[df, losses] = initial_cleaning(df, losses);

% Realiza operacoes nas features, removendo e criando novas no subset de selecao
df = featurize(df, (losses > 0));

% Normalizando dados
fprintf('Normalizando dados...\n\n');
dfx = normalize(df);

% Separa dados para treinamento e teste
fprintf('Separando dados de treinamento e testes...\n\n');
[testing, training, labels, training_labels] = separate_data(dfx, losses, .3);

training_labels_bool = training_labels > 0;
labels_bool = labels > 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRID SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if GRID_SEARCH
  fprintf('Iniciando grid search...\n\n');

  fprintf('Grid search para kNN...\n\n');

  upper_bound = floor(sqrt(size(training, 1)));
  range = (1 : 2 : upper_bound);

  [c, ~, knn_grid_errors] = grid_search(training, training_labels_bool, @apply_knn, @knn_error, range);

  plot(knn_grid_errors(:,1),knn_grid_errors(:,2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLASSIFICADORES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


run_method('KNN', labels_bool, ...
  @()(apply_knn(testing, training, training_labels_bool, 3)));

run_method('Regressao logistica', labels_bool, ...
  @()(apply_reglog(testing, training, training_labels_bool)));
