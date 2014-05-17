function Imorph = morph(I1, I2, pt1, pt2, t, tri)
%% ========================================================================
%%
%% Written by Wai Khoo
%%
%% Computing a morph at time t using triangulation
%%
%% Input:   I1, I2   -- Begin- and End- pictures, respectively (input
%%                      images)
%%          pt1, pt2 -- vectors with the vertex points for the begin- and
%%                      end- pictures, respectively
%%          t        -- the morph time
%%
%% Output:  Imorph   -- morphed image between I1 and I2 at time t.
%%
%% ========================================================================

[ROWS COLS CHANNELS] = size(I1);
Imorph =uint8(zeros(ROWS, COLS, CHANNELS));

u = (1-t).*pt1 + t.*pt2;

% 3 vertices of a triangle
v1 = u(tri(:,1),:);
v2 = u(tri(:,2),:);
v3 = u(tri(:,3),:);

% computing the sign of the triangle
s = sign(v1(:,1).*v2(:,2) - v1(:,2).*v2(:,1) + v2(:,1).*v3(:,2) - v2(:,2).*v3(:,1) + v3(:,1).*v1(:,2) - v3(:,2).*v1(:,1));
c12 = s.*(v1(:,2) - v2(:,2));
c23 = s.*(v2(:,2) - v3(:,2));
c31 = s.*(v3(:,2) - v1(:,2));
d12 = s.*(v1(:,1) - v2(:,1));
d23 = s.*(v2(:,1) - v3(:,1));
d31 = s.*(v3(:,1) - v1(:,1));
e12 = s.*(v1(:,1).*v2(:,2) - v1(:,2).*v2(:,1));
e23 = s.*(v2(:,1).*v3(:,2) - v2(:,2).*v3(:,1));
e31 = s.*(v3(:,1).*v1(:,2) - v3(:,2).*v1(:,1));

% determine the boundary of the triangle (a square, basically)
xMin = round(min([v1(:,1), v2(:,1), v3(:,1)], [], 2));
xMax = round(max([v1(:,1), v2(:,1), v3(:,1)], [], 2));
yMin = round(min([v1(:,2), v2(:,2), v3(:,2)], [], 2));
yMax = round(max([v1(:,2), v2(:,2), v3(:,2)], [], 2));

for k = 1:size(tri,1)
    % [x y 1]' = [Uix Ujx Ukx; Uiy Ujy Uky; 1 1 1]*[Ci Cj Ck]'
    M = [cat(2,v1(k,:),1)' cat(2,v2(k,:),1)' cat(2,v3(k,:),1)'];

    %% solve the system using least square method
    M_pseudo = pseudoInv(M);

    for i = yMin(k):yMax(k)
        for j = xMin(k):xMax(k)
            % a point is within the triangle if it has the same sign for
            % all 3 lines.
            triangle = (c12(k)*j - d12(k)*i + e12(k) >=0) & (c23(k)*j - d23(k)*i + e23(k) >= 0) & (c31(k)*j - d31(k)*i + e31(k) >= 0);
            if triangle == 1
                c = M_pseudo*M'*[j i 1]';
                    
                %% determine the current point in begin- and end-pictures  
                v = c(1)*pt1(tri(k,1),:) + c(2)*pt1(tri(k,2),:) + c(3)*pt1(tri(k,3),:); %% begin-
                w = c(1)*pt2(tri(k,1),:) + c(2)*pt2(tri(k,2),:) + c(3)*pt2(tri(k,3),:); %% end-

                %% Boundary check
                % left and bottom bound check
                v(v<1) = 1;
                w(w<1) = 1;

                % right-bound check
                if v(1) > COLS
                    v(1) = COLS;
                end
                if w(1) > COLS
                    w(1) = COLS;
                end

                % top-bound check
                if v(2) > ROWS
                    v(2) = ROWS;
                end
                if w(2) > ROWS
                    w(2) = ROWS;
                end

                v = round(v);
                w = round(w);

               Imorph(i,j) = (1-t)*I1(v(2),v(1)) + t*I2(w(2),w(1));
            end
        end
   end
end