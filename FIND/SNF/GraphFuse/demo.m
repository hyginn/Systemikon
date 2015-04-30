clear all;close all;clc
%Demo of the GraphFuse Algorithm, by E. Papalexakis, L. Akoglu, D. Ienco,
%Fusion 2013
load data/planted/planted1/A.mat
load data/planted/planted1/planted1_labels.mat

K = size(A,2);
%create the tensor
[I J] = size(A{1});
X = zeros(I,J,K);
for i = 1:K
    X(:,:,i) = A{i};
end
X = sptensor(X);


lambda = 1;% for synthetic
R = max(labels);%number of components
[labels_i labels_j] = GraphFuse(X,R,lambda)
