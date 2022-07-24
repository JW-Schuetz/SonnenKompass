function Symmetrie
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'dMinusAlpha' )

    omega  = sym( 'omega', 'real' );
    alpha  = sym( 'alpha', 'real' );
    psi    = sym( 'psi', 'real' );

    dMinusAlpha = subs( dMinusAlpha, cos( alpha ), ...
        sin( alpha ) * cos( omega ) * cos( psi ) / sin( omega ) );

    dMinusAlpha = simplify( dMinusAlpha )

    d1 = dMinusAlpha( 3 )
end
