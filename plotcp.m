%% Plot Cp

% Cp curve modeling
% lambdaai = 1/(1/(lambda+0.08*beta)) - 0.035/(beta^3+1))
% cp = c1*(c2/lambdaai-c3*beta-c4)*exp(-c5/lambdaai) + c6*lambda
wt.c = [...
    0.5176 ...
    116 ...
    0.4 ...
    5 ...
    21 ...
    0.0068];

% Uncomment below to plot Cp
figure
lambda = [0:0.1:13];
for beta = [0:5:30];
    lambdaai = 1./(1./(lambda+0.08*beta) - 0.035./(beta.^3+1));
    cp = wt.c(1)*(wt.c(2)./lambdaai - wt.c(3)*beta - wt.c(4)) .* exp(-wt.c(5)./lambdaai) + wt.c(6)*lambda;
    hold on
    plot(lambda,cp)
    hold off
end
axis([0 13 0 0.5])
xlabel('lambda (tip speed ratio)')
ylabel('Cp')