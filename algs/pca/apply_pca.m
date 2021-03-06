function [df, U, S] = apply_pca(dataframe, K)
  if nargin <= 1
    K = -1;
  end

  fprintf('\tAplicando PCA...\n\n');

  [U, S] = pca(dataframe);

  fprintf('\t\tBuscando o melhor K...\n\n');

  m = size(S, 1);
  diagonal = diag(S);
  total = sum(diagonal);

  fprintf('\t\t\tK = ');

  if K == -1
    for k = 1 : m
      fprintf('%d', k);

      c = sum(diagonal(1 : k)) / total;

      if (1 - c <= 0.01)
        fprintf('.');
        break;
      end

      fprintf(', ');
    end
  else
    k = K;
    fprintf('%d.', k);
  end

  fprintf('\n\n\t\tMELHOR K = %d! (perda = %d)\n\n', k, 1 - (sum(diagonal(1 : k)) / total));

  df = projetarDados(dataframe, U, k);
