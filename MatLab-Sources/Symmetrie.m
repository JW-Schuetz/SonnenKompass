function Symmetrie
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'dMinusAlpha' )

    omega = sym( 'omega', 'real' );
    alpha = sym( 'alpha', 'real' );
    psi   = sym( 'psi', 'real' );

    dMinusAlpha = subs( dMinusAlpha, alpha, str2sym( 'alpha' ) );

    dMinusAlpha = simplify( dMinusAlpha, 'Steps', 100 );
    [ z, n ] = numden( dMinusAlpha );

    n
    simplify( z, 'Steps', 100 )
end