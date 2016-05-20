function [] = do_grid_search(dfx, losses)
  % Separa dados para grid search
  fprintf('Separando dados para grid search...\n\n');
  [testing, training, labels, training_labels] = separate_data(dfx, losses, .3);

  training_labels_bool = double(training_labels > 0);

  fprintf('Iniciando grid search...\n\n');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  upper_bound = floor(sqrt(size(training, 1)));

  if mod(upper_bound, 2) == 0
    upper_bound = upper_bound - 1;
  end

  constants = [3 5 9 ceil(upper_bound / 2) upper_bound];

  call_grid('kNN', 'K', ...
   constants, training, training_labels_bool, @apply_knn, @knn_error);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  constants = (1 : 16) * 2;

  call_grid('Regressao Logistica', '\lambda', ...
    constants, training, training_labels_bool, @apply_reglog, @reglog_error);