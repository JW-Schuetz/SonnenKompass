clc
clear

x = sym( 'x', 'real' );
y = sym( 'y', 'real' );

t = sin( x ) + x^3;

symvar( t )
collect( t, y )