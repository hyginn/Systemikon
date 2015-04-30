function [A B C cost]=SPARAFAC_TT(X,F,lambda)
%Sparse PARAFAC decomposition with Non-negativity Constraints, for balanced
%sparsity
%Nikos Sidiropoulos, Vagelis Papalexakis, 2011

% SMALLNUMBER = 10^8*eps;
SMALLNUMBER=10^-4;
MAXNUMITER = 20;

s = size(X); I=s(1);J=s(2);K=s(3);

factors = cp_nmu(X,F);
A=sparse(factors.U{1});B=sparse(factors.U{2});C=sparse(factors.U{3});

 disp('Initializing')
% [A B C] = naive_als(X,F);
%  A = sprand(I,F,1); B = sprand(J,F,1); C = sprand(K,F,1);
disp('Unfolding')
UA = (sptenmat(X,1,'bc')); UA = sparse(UA.subs(:,1), UA.subs(:,2),UA.vals,size(UA,1),size(UA,2));UA = UA';
UB = (sptenmat(X,2,'bc'));  UB = sparse(UB.subs(:,1), UB.subs(:,2),UB.vals,size(UB,1),size(UB,2));UB = UB';
UC = (sptenmat(X,3,'bc'));  UC = sparse(UC.subs(:,1), UC.subs(:,2),UC.vals,size(UC,1),size(UC,2));UC = UC';
    
    disp('Initial estimates')

cost = norm(UA - khatrirao(B,C)*A','fro')^2  + +lambda*sum(sum(abs(A))) + lambda*sum(sum(abs(B))) + lambda*sum(sum(abs(C)));

costold = 2*cost;
it = 0;
while abs((cost-costold)/costold) > SMALLNUMBER && it < MAXNUMITER && cost > 10^5*eps
    it=it+1;
    costold=cost;
    % re-estimate A:
    A = NNSMREW(UA,sparse(khatrirao(B,C)),A,lambda);
    % re-estimate B:
    B = NNSMREW(UB,sparse(khatrirao(C,A)),B,lambda);
    % re-estimate C:
    C = NNSMREW(UC,sparse(khatrirao(A,B)),C,lambda);


    cost = norm(UA - khatrirao(B,C)*A','fro')^2;  
    cost = cost + lambda*sum(sum(abs(A))) + lambda*sum(sum(abs(B))) + lambda*sum(sum(abs(C)));  
    fprintf('iteration: %d cost: %12.10f diff: %.12f\n',it,cost,abs((cost-costold)/costold));

end

end

function AkrpB = krp(A,B)

[I F] = size(A);
[J F1] = size(B);

if (F1 ~= F)
 disp('krp.m: column dimensions do not match!!! - exiting matlab');
%  exit;
end

AkrpB = [];
for f=1:F,
 AkrpB = [AkrpB kron(A(:,f),B(:,f))];
end
end

function B = NNSMREW(X,A,B,lambda)

% Non-negative sparse matrix regression
% using element-wise coordinate descent
% Given X, A, find B to
% min ||X-A*B.'||_2^2 + lambda*sum(sum(abs(B)))
%
% Subject to: B(j,f) >= 0 for all j and f
%
% N. Sidiropoulos, August 2009
% nikos@telecom.tuc.gr


[I,J]=size(X);
[I,F]=size(A);

DontShowOutput = 1;
maxit=10000;
convcrit = 1e-9;
showfitafter=1;
it=0;
Oldfit=1e100;
Diff=1e100;

while Diff>convcrit && it<maxit
    it=it+1;
    for j=1:J,
        for f=1:F,
            data = X(:,j) - A*B(j,:).' + A(:,f)*B(j,f);
            alpha = A(:,f);
          
            if ((alpha.'*data - lambda/2) > 0)
                B(j,f) = (alpha.'*data - lambda/2)/(alpha.'*alpha);
            else
                B(j,f) = 0;
            end
        end
    end

    fit=norm(X-A*B.','fro')^2+lambda*sum(sum(abs(B)));
    if Oldfit < fit
%         disp(['*** bummer! *** ',num2str(Oldfit-fit)])
    end
    Diff=abs(Oldfit-fit);
    Oldfit=fit;

    if ~DontShowOutput
        % Output text
        if rem(it,showfitafter)==0
            disp([' NNSMREW Iterations:', num2str(it),' fit: ',num2str(fit)])
        end
    end
end
B = sparse(B);
end