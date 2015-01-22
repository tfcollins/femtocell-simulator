function viewPositions( gridSize, AccessPoints, fignum)

x = gridSize(1);
y = gridSize(2);
figure(fignum)

for ap = 1:length(AccessPoints)
    apPositions = AccessPoints{ap}.apPosition; 
    hold on; fh2 = scatter(apPositions(1),apPositions(2),'bx');hold off;
    set(fh2,'LineWidth',5);
end

% set(fh1,'LineWidth',5);

axis([1 x 1 y]);
xlabel('Meters');
ylabel('Meters');
legend('AP','Receiver');
grid on;
