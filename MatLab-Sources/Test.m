function Test()
    clc
    clear

    % zu Projizieren
    x0 = [ rand; rand ];

    % y = ax + b  <-->  -ax + y = b
    a = 3.4;
    b = -1.112;

    s = [ -a; 1 ];
    n = s / norm( s );

%     x0S = x0 + ( n * x0' ) * n;
    x0S = [ 1 + n( 1 )^2, n( 1 ) * n( 2 ); n( 1 ) * n( 2 ), 1 + n( 2 )^2 ] * x0;

    % Plotten der Ergebnisse
    figure

    hold( 'on' )
    box( 'on' )
    grid( 'on' )
    axis( 'equal' )

    xlim( [ -10, 10 ] );
    ylim( [ -10, 10 ] );

    xl = xlim;
    x  = xl( 1 ) : 0.1 : xl( 2 );

    N = length( x );
    y = zeros( N, 1 );

    for n = 1 : N
        y( n ) = fun( a, b, x( n ) );
    end

	plot( 0, 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k' )
	plot( x0( 1 ), x0( 2 ), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k' )
	plot( x0S( 1 ), x0S( 2 ), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k' )

    plot( x, y )
    plot( [ x0( 1 ), x0S( 1 ) ], [ x0( 2 ), x0S( 2 ) ] )
end

function res = fun( a, b, x )
    res = a * x + b;
end