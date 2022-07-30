function Symmetrie
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'dMinusAlpha' )

    omega = sym( 'omega', 'real' );
    alpha = sym( 'alpha', 'real' );
    psi   = sym( 'psi', 'real' );

    dMinusAlpha = subs( dMinusAlpha, alpha, ...
        atan( tan( omega ) / cos( psi ) ) );

    dMinusAlpha = simplify( dMinusAlpha, 'Steps', 100 );
    [ z, n ] = numden( dMinusAlpha );

    n
    simplify( z, 'Steps', 100 )
end