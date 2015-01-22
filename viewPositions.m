function viewPositions( gridSize, AccessPoints, fignum, observer)

x = gridSize(1);
y = gridSize(2);
figure(fignum)

hold on; fh2 = scatter(observer(1),observer(2),'gx');hold off;
set(fh2,'LineWidth',5);

for ap = 1:length(AccessPoints)
    apPositions = AccessPoints{ap}.apPosition; 
    hold on; fh2 = scatter(apPositions(1),apPositions(2),'bx');hold off;
    set(fh2,'LineWidth',5);
end


axis([1 x 1 y]);
xlabel('Meters');
ylabel('Meters');
legend('Observer','AP');
grid on;
