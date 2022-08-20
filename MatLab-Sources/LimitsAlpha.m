function LimitsAlpha
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'pSAlpha' )

    alpha = sym( 'alpha', 'real' );

    % Koeffizienten A,B und C von pSAlpha bestimmen: "A*sin(alpha)+B*cos(alpha)+C"
    [ s, ~ ] = coeffs( pSAlpha, sin( alpha ) );
    A = s( 1 );

    [ s, ~ ] = coeffs( s( 2 ), cos( alpha ) );
    B = s( 1 );
    C = s( 2 );

    g = A * sin( alpha ) + B * cos( alpha ) + C;

    % Check it!
    if( simplify( pSAlpha - g ) ~= 0 )
        error( 'Check failed!') % muss 0 ergeben
    end

    % Gleichung "a*sin(alpha)+b*cos(alpha)+c==0" lösen
    a = sym( 'a', 'real' );
    b = sym( 'b', 'real' );
    c = sym( 'c', 'real' );

    ret = solve( a * sin( alpha ) + b * cos( alpha ) + c == 0, alpha, ...
                'ReturnConditions', true, 'Real', true );

    A %#ok<NOPRT> 
    B %#ok<NOPRT> 
    C %#ok<NOPRT> 

    ret.alpha( 1 )
    ret.alpha( 2 )
    ret.conditions( 1 )
    ret.conditions( 2 )
end