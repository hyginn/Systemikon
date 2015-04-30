function [labels_i labels_j] = GraphFuse(X,R,lambda)
%GraphFuse Gene Data

s = size(X);
I = s(1); J = s(2); K = s(3);
[A B C] = SPARAFAC_TT(X,R,lambda);

labels_i = zeros(I,1);
labels_j = zeros(J,1);

for i = 1:I
    a = A(i,:);
    [junk idx] = max(a);
    A(i,:) = 0;
    A(i,idx) = junk;
    labels_i(i) = idx;
    if sum(a) == 0
        labels_i(i) = R+1;%if not assigned to any known label, make a new one
    end
end
for i = 1:J
    b = B(i,:);
    [junk idx] = max(b);
    B(i,:) = 0;
    B(i,idx) = junk;
    labels_j(i) = idx;
    if sum(b) == 0
        labels_j(i) = R+1;%if not assigned to any known label, make a new one
    end
end
