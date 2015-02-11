%
points = 1e4;
means = 10;
integrals = zeros(points,means);
for numberOfUsers = 10:10:100;
    LAMBDA = numberOfUsers;
    R = poissrnd(LAMBDA,points*10,1);
    integral = cumsum(hist(R,points)).';
    integrals(:,numberOfUsers) = integral;
    
end
numberOfUsers = 10:10:100;
plot(integrals);
legend('10','20','30','40','50','60','70','80','90','100');