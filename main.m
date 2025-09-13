% Vector Quantization: K-Means Algorithm with Spliting Method for Training
% NOT TESTED FOR CODEBOOK SIZES OTHER THAN POWERS OF BASE 2, E.G. 256, 512, ETC
% (Saves output to a mat file (CBTEMP.MAT) after each itteration, so that if
% it is going too slow you can break it (CTRL+C) without losing your work
% so far.)
% [M, P, DH]=VQSPLIT(X,L)
% 
% or
% [M_New, P, DH]=VQSPLIT(X,M_Old)   In this case M_Old is a codebook and is
%                                   retrained on data X
% 
% inputs:
% X: a matrix each column of which is a data vector
% L: codebook size (preferably a power of 2 e.g. 16,32 256, 1024) (Never
% tested for other values!
% 
% Outputs:
% M: the codebook as the centroids of the clusters
% P: Weight of each cluster the number of its vectors divided by total
%       number of vectors
% DH: The total distortion history, a vector containing the overall
% distortion of each itteration
%
% Method:
% The mean vector is split to two. the model is trained on those two vectors
% until the distortion does not vary much, then those are split to two and
% so on. until the disired number of clusters is reached.
% Algorithm:
% 1. Find the Mean
% 2. Split each centroid to two
% 3. Assign Each Data to a centroid
% 4. Find the Centroids
% 5. Calculate The Total Distance
% 6. If the Distance has not changed much
%       if the number of Centroids is smaller than L2 Goto Step 2
%       else Goto 7
%    Else (the Distance has changed substantialy) Goto Step 3
% 7. If the number of Centroids is larger than L
%    Discard the Centroid with (highest distortion OR lowest population)
%    Goto 3
% 8. Calculate the Variances and Cluster Weights if required
% 9. End
%


e=.01; % X---> [X-e*X and X+e*X] Percentage for Spliting
eRed=0.75; % Rate of reduction of split size, e, after each spliting. i.e. e=e*eRed;
DT=.005; % The threshold in improvement in Distortion before terminating and spliting again
DTRed=0.75; % Rate of reduction of Improvement Threshold, DT, after each spliting
MinPop=0.10; % The population of each cluster should be at least 10 percent of its quota (N/LC)
             % Otherwise that codeword is replaced with another codeword

figure();
subplot(2,2,1);
x = [0 0.0001 0.5 1 1.5 2 2.5 3 3.5 4 ];
y = [1.2 -0.5 -0.35 0 -0.25 -0.55 -0.35 -0.25 -0.15 -0.11];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold on;
y = [1.7 -0.35 -0.32 0 -0.15 -0.35 -0.25 -0.15 -0.12 -0.11];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold off;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Reactive Power'), title('LOE event'), axis([0 4 -1 2])

subplot(2,2,2);

x = [0 0.0001 0.5 1 1.5 2 2.5 3 3.5 4];
y = [3.5 1.2 1.1  0.89 0.74 0.67 0.59 0.52 0.5 0.48];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold on;
y = [3.5 1.1 1.01 0.88 0.73 0.61 0.51 0.5 0.48 0.4];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold off;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Terminal Voltage'),  title('LOE event'),axis([0 4 0 4])


subplot(2,2,3);
x = [0 0.0001 0.5 0.99 1     1.0001   1.001 1.01    1.2 1.2001  1.3 1.3001  1.4 1.4001  1.5  1.5001 1.5999 1.6 1.6001 1.6002 1.6888  1.7  1.8  1.9   1.98   2   2.2 2.1 2.2 2.3 2.4 2.5  ];
y = [0.3 -1.2 0   0 11    -0.9      2     1       3    4      3   4        3   4       3    4         4 18   18       2    2     2     2   1.7   -0.8  -1  3 2  2.5 2.5  2   0];
grid on
plot(x,y,'b',"LineWidth",1.1);
hold on;  
y = [0.2 -1   0  0  11    -0.9      2     1       3    4      3   4        3   4       3    4         4 17   17     2  2      1.8   1.8  1.5   -1   -1  2 2  2.1    2.5  2.5 0];
grid on
plot(x,y,'r',"LineWidth",1.5);
hold off;
legend('SPS WO UPFC', 'SPS W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Reactive Power'), title('SPS event'), axis([0 2.5 -5 20])



subplot(2,2,4);
x = [0 0.0001 0.5 0.99 1     1.0001   1.001 1.01    1.2 1.2001  1.3 1.3001  1.4 1.4001  1.5  1.5001 1.5999 1.6 1.6001 1.6002 1.6888  1.7  1.8  1.9   1.98   2   2.2 2.1 2.2 2.3 2.4 2.5  ];
y = [0.3 -1.2 0   0 4    -0.9      2     1       3    4      3   4        3   4       3    4         4 8   8       2    2     2     2   1.7   -0.8  -1  3 2  2.5 2.5  2   0];
grid on
plot(x,y,'b',"LineWidth",1.1);
hold on;  
y = [0.2 -1   0  0  3    -0.9      2     1       3    4      3   4        3   4       3    4         4 9   9     2  2      1.8   1.8  1.5   -1   -1  2 2  2.1    2.5  2.5 0];
grid on
plot(x,y,'r',"LineWidth",1.5);
hold off;
legend('SPS WO UPFC', 'SPS W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Terminal Voltage'), title('SPS event'), axis([0 2.5 -2 10])

figure();
subplot(2,1,1);
x = [0 0.0001 0.5 0.52 1     1.1  1.2  1.3   1.4   1.5 1.7 2    2.5  3    3.5 4];
y = [0 0.45   0.6  0.6 0.54  0.57 0.55 0.55  0.55  0.6 0.7 0.75 0.75 0.77 0.8 0.82];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold on;
y = [0 0.43   0.58  0.58 0.52  0.55 0.52 0.52  0.52  0.58 0.67 0.72 0.72 0.74 0.77 0.8];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold off;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Stator Current'), title('LOE event'), axis([0 4 -1 2])

subplot(2,1,2);
x = [0  0.1     0.2     0.3      0.4   0.5      0.6     0.7  0.8  0.9    1     1.1   1.2     1.3 ];
y = [0 -0.002 -0.0025 -0.0025 -0.002  -0.0015  -0.001 -0.01   0   0.0001 0.001 0.001  0.0001 0];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold on;
y = [0 -0.002 -0.003 -0.003   -0.0025 -0.0015  -0.001 -0.01   0   0.0001 0.002 0.002 0.0001 0];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold off;

legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Terminal Voltage'),  title('LOE event'),axis([0 1.5 -0.004 0.003])


figure();
subplot(2,1,1);
x = [0 0.0001 0.5  0.70  0.75  0.80   1    1.2  1.25   1.3   1.5    1.75  2      2.5  3     3.5  4];
y = [0 0.45   0.6  0.62  0.64  0.60  0.54  0.57  0.5   0.57  0.62    0.7  0.73    0.7 0.74  0.8  0.81];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold on;
y = [0 0.43  0.58  0.60  0.64  0.60  0.55  0.52  0.5    0.52  0.62   0.7  0.73   0.7  0.71  0.8  0.82];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold on;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Stator Current'), title('LOE event'), axis([0 4 0 0.9])

subplot(2,1,2);
x = [0  0.2     0.3    0.33     0.4     0.5   0.7     0.8];
y = [0 -0.001 -0.0025  -0.001 -0.001  -0.001    -0.001    -0.001 ];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold on;
y = [0 -0.001  -0.002  -0.001  -0.0028  0   -0.001  -0.0015   ];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold off;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('%s'), subtitle('Slip Percentage'), title('LOE event'), axis([0 1 -0.004 0.004])
N=20;
Population=200;
p=Population/N;
input_vectors =[3 2; 7 6; 2 3; 6 7; 1 2; 5 6; 2 1; 6 5]';
output_targets = [1 2 1 2 1 2 1 2];
input_size = length(input_vectors);
learning_rate = 0.1;
W1 = input_vectors(:,1);
W2 = input_vectors(:,2);
for a = 1:50
 for n = 1:input_size
 X1 = norm((input_vectors(:,n)-W1))^2;
 X2 = norm((input_vectors(:,n)-W2))^2;
 x = min(X1,X2);
 if x == X1 && output_targets(n) == 1
 W1 = W1 + learning_rate*(input_vectors(:,n)-W1);
 elseif x == X1 && output_targets(n) == 2
 W1 = W1 - learning_rate*(input_vectors(:,n)-W1);
 elseif x == X2 && output_targets(n) == 2
 W2 = W2 + learning_rate*(input_vectors(:,n)-W2);
 elseif x == X2 && output_targets(n) == 1
 W2 = W2 - learning_rate*(input_vectors(:,n)-W2);
 end
 end
end
disp(['The learning vector W1 = ']);disp(W1)
disp(['The learning vector W2 = ']);disp(W2)
hold on
plot(input_vectors(1,:),input_vectors(2,:),'bo','LineWidth',2);
plot(W1(1,:),W1(2,:),'r*','LineWidth',1);
plot(W2(1,:),W2(2,:),'y*','LineWidth',1);
hold off
legend('input vector','W1','W2');
title('Learning Vector Quantization')
figure();
subplot(2,1,1);
x = [0 0.0001 0.5  0.70  0.75  0.80   1    1.2  1.25   1.3   1.5    1.75  2      2.5  3     3.5  4];
y = [0 0.45   0.6  0.62  0.64  0.60  0.54  0.57  0.5   0.57  0.62    0.7  0.73    0.7 0.74  0.8  0.81];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold on;
y = [0 0.43  0.58  0.60  0.64  0.60  0.55  0.52  0.5    0.52  0.62   0.7  0.73   0.7  0.71  0.8  0.82];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold on;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('pu'), subtitle('Stator Current'), title('LOE event'), axis([0 4 0 0.9])

subplot(2,1,2);
x = [0  0.2     0.3    0.33     0.4     0.5   0.7     0.8];
y = [0 -0.001 -0.0025  -0.001 -0.001  -0.001    -0.001    -0.001 ];
grid on
plot(x,y,'b',"LineWidth",1.5);
hold on;
y = [0 -0.001  -0.002  -0.001  -0.0028  0   -0.001  -0.0015   ];
grid on
plot(x,y,'y',"LineWidth",1.5);
hold off;
legend('LOE WO UPFC', 'LOE W UPFC'), xlabel('Time (s)'),ylabel('%s'), subtitle('Slip Percentage'), title('LOE event'), axis([0 1 -0.004 0.004])



sim('IEEE_SMIB_Synch.slx');
stability;

