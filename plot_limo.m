X = data(:,4);
Z = data(:,12);

center_x = (min(X) + max(X))/2;
center_z = (min(Z) + max(Z))/2;

X_range = max(X)-min(X);
Z_range = max(Z)-min(Z);

if X_range > Z_range
   A_range = X_range
else
   A_range = Z_range; 
end

plot(X,Z,'*')
axis([center_x - A_range/2, center_x + A_range/2, center_z - A_range/2, center_z + A_range/2])
grid on
xlabel('x (m)')
ylabel('z (m)')
title('Pose X vs Z, sequence 1, rate 0.1')