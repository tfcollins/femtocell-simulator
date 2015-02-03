function viewPositions( gridSize, AccessPoints, fignum, observer)

x = gridSize(1);
y = gridSize(2);
figure(fignum)

fh2 = scatter(observer(1),observer(2),'gx');
set(fh2,'LineWidth',5);

for ap = 1:length(AccessPoints)
    apPositions = AccessPoints{ap}.apPosition; 
    hold on; fh2 = scatter(apPositions(1),apPositions(2),'bx');hold off;
    set(fh2,'LineWidth',5);
end

hold on; fh2 = scatter(observer(1),observer(2),'gx');hold off;
set(fh2,'LineWidth',5);

axis([-x*0.15 x+x*0.15 -y*0.15 y+y*0.15]);
xlabel('Meters');
ylabel('Meters');
legend('Observer','AP');
grid on;
