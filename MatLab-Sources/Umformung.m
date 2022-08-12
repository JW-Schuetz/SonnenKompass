function Umformung()
    clc
    clear

    psi   = sym( 'psi', 'real' );
    alpha = sym( 'alpha', 'real' );
    omega = sym( 'omega', 'real' );

    alphaM = atan( tan( omega ) * cos( psi ) );

    simplify( cos( alpha - alphaM ), 'Steps', 100 )
    simplify( sin( alpha - alphaM ), 'Steps', 100 )
end