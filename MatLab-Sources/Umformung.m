function Umformung()
    clc
    clear

    psi   = sym( 'psi', 'real' );
    alpha = sym( 'alpha', 'real' );
    omega = sym( 'omega', 'real' );
    delta = sym( 'delta', 'real' );

    alphaM = atan( tan( omega ) / cos( psi ) );

    c = cos( alpha );
    s = sin( alpha );

    c = subs( c, 'alpha', alphaM - delta );
    s = subs( s, 'alpha', alphaM - delta );

    simplify( c, 'Steps', 100 )
    simplify( s, 'Steps', 100 )
end