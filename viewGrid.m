function viewGrid(grid, gridID)

figure(gridID);
surf(grid)
view(0,90)
xlabel('Resource Blocks (Time 1 Block=0.5ms)');
ylabel('Resource Blocks (Frequency 1 Block=180KHz)');

end