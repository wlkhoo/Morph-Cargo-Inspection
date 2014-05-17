function pseudo = pseudoInv(A)
%% ========================================================================
%%
%% Written by Wai Khoo
%%
%% Computing the pseudoinverse using the least square method, which is
%% optimal
%%            x = (A'A)^+ A'b    Note: the '+' means pseudoinverse
%%
%% Input:    A        -- M x N matrix which contains the coefficients of the 
%%                        equations
%%
%% Output:   pseudo   -- pseudoinverse of A, i.e. (A'A)^+
%%
%% ========================================================================

temp = A'*A;
[m n] = size(temp);
[U, S, V] = svd(temp);
r = rank(S);
SR = S(1:r, 1:r);
SRc = [SR^-1 zeros(r, m-r); zeros(n-r, r) zeros(n-r, m-r)];
pseudo = V*SRc*U'; 