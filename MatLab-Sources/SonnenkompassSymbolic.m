%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassSymbolic
    clc
    clear

    % symbolische Variablen
    omega  = sym( 'omega', 'real' );            % Jahreszeit
    thetaG = sym( 'thetaG', 'real' );           % Geographische Breite des Stabes
    psi    = sym( 'psi', 'real' );              % Komplementwinkel Erd-Rotationsachse zur Ekliptik
    rS     = sym( 'rS', 'real' );               % Abstand Erde - Sonne
    rE     = sym( 'rE', 'real' );               % Erdradius
    lS     = sym( 'lS', 'real' );               % Stablänge
    e      = sym( 'e', [ 3, 1 ], 'real' );      % Einheitsvektor Rotationsachse
    alpha  = sym( 'alpha', 'real' );            % Tageszeit, Erd-Rotationswinkel (2*pi/24h)
    dAlpha = sym( 'dAlpha', [ 3, 3 ], 'real' );	% Drehmatrix
    p      = sym( 'p', [ 3, 1 ], 'real' );      % Fusspunkt des Stabes auf der Erdoberfläche und Stabende
    s      = sym( 's', [ 3, 1 ], 'real' );      % Sonnenposition in Bezug zum Erdmittelpunkt

    % der Längengrad ist stets 0° (siehe Annahmen)
    p( 2 ) = 0;

    % Einheitsvektor Erd-Rotationsachse
    e( 1 ) = sin( psi );
    e( 2 ) = 0;
    e( 3 ) = cos( psi );

    % Drehmatrix
    ca = cos( alpha );
    sa = sin( alpha );

    dAlpha( 1, 1 ) = e( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
    dAlpha( 2, 1 ) = e( 2 ) * e( 1 ) * ( 1 - ca ) + e( 3 ) * sa;
    dAlpha( 3, 1 ) = e( 3 ) * e( 1 ) * ( 1 - ca ) - e( 2 ) * sa;

    dAlpha( 1, 2 ) = e( 1 ) * e( 2 ) * ( 1 - ca ) - e( 3 ) * sa;    % 2. Spalte
    dAlpha( 2, 2 ) = e( 2 )^2        * ( 1 - ca ) + ca;
    dAlpha( 3, 2 ) = e( 3 ) * e( 2 ) * ( 1 - ca ) + e( 1 ) * sa;

    dAlpha( 1, 3 ) = e( 1 ) * e( 3 ) * ( 1 - ca ) + e( 2 ) * sa;    % 3. Spalte
    dAlpha( 2, 3 ) = e( 2 ) * e( 3 ) * ( 1 - ca ) - e( 1 ) * sa;
    dAlpha( 3, 3 ) = e( 3 )^2        * ( 1 - ca ) + ca;

    % Stabendpunkt
    q = ( 1 + lS / rE ) * p;

    % Sonnenposition im Jahresverlauf
    s( 1 ) = rS * cos( omega );
    s( 2 ) = rS * sin( omega );
    s( 3 ) = 0;

    % die Sonne um -alpha drehen
    dMinusAlpha = subs( dAlpha, 'alpha', str2sym( '-alpha' ) );

    % das müsste doch eigentlich einfacher gehen!
    dM11 = dMinusAlpha( 1, 1 ); 
    dM11 = collect( dM11, cos( alpha ) ); 
    dM11 = subs( dM11, sin( psi )^2, 1 - cos( psi )^2 );
    dM11 = subs( dM11, -cos( psi )^2 + 1, sin( psi )^2 );

    dM12 = dMinusAlpha( 1, 2 );
    dM13 = dMinusAlpha( 1, 3 );
    dM13 = collect( dM13, cos( alpha ) );
    dM21 = dMinusAlpha( 2, 1 );
    dM22 = dMinusAlpha( 2, 2 );
    dM23 = dMinusAlpha( 2, 3 );
    dM31 = dMinusAlpha( 3, 1 );
    dM31 = collect( dM31, cos( alpha ) );
    dM32 = dMinusAlpha( 3, 2 );

    % das müsste doch eigentlich einfacher gehen!
    dM33 = dMinusAlpha( 3, 3 ); 
    dM33 = collect( dM33, cos( alpha ) ); 
    dM33 = subs( dM33, cos( psi )^2, 1 - sin( psi )^2 );
    dM33 = subs( dM33, -sin( psi )^2 + 1, cos( psi )^2 );

    dMinusAlpha = [ ...
        dM11, dM12, dM13; ...
        dM21, dM22, dM23; ...
        dM31, dM32, dM33; ...
    ];

    sAlpha = dMinusAlpha * s;

    % PSAlpha als Koeffizienten des Vektors P ausdrücken 
    pSAlpha = collect( p' * sAlpha, p );

    % omegaS bestimmen
    omegaS = simplify( rE - pSAlpha / rE );
    omegaS = omegaS / lS;

    % mue0 bestimmen
    mue0 = omegaS / ( 1 + omegaS );

    % die dreidimensionale Trajektorie bestimmen
    x0 = mue0 * q + ( 1 - mue0 ) * sAlpha;

    % die zweidimensionale Trajektorie bestimmen
    y0 = MapToPlane( x0, thetaG, psi );

    % Ableitung der Trajektorien-Komponenten nach alpha bestimmen
    y0Strich = simplify( diff( y0, 'alpha' ) );

    % Trajektoriensteigung
    y0Strich = y0Strich( 2 ) / y0Strich( 1 );

    % Trennung: Zähler - Nenner
    [ n, d ] = numden( y0Strich );

    y0StrichNom   = simplify( n );
    y0StrichDenom = simplify( d );

    % Test der Trajektoriensymmetrie in Bezug zum astronomischen Mittag
    symmetrieTest( omega, psi, p, pSAlpha, mue0, x0, y0 )

    save( 'SonnenkompassSymbolic.mat', 'alpha', 'x0', 'y0', 'y0StrichNom', ...
          'y0StrichDenom', 'mue0', 'pSAlpha' )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = MapToPlane( x0, thetaG, psi )
    theta = thetaG - psi;

    % Punkt drehen um x2-Achse und den Winkel theta
    if( theta ~= 0 )
        x = rotateX2( theta, x0 );
    end

    % Projizieren auf die Tangentialebene
    A = [ 0, 1, 0; 0, 0, 1 ];
    y = A * x;
end

function x = rotateX2( theta, x )
    % Punkt drehen um x2-Achse und den Winkel theta
    c = cos( theta );
    s = sin( theta );

    D = [  c, 0, s;
           0, 1, 0;
          -s, 0, c ];

    x = D * x;
end

function txt = symmetrieTest( omega, psi, p, pSAlpha, mue0, x0, y0 )
    eps    = sym( 'eps', 'real' );
    alphaM = atan( tan( omega ) / cos( psi ) ) + pi;

    txt = '';
    x1  = simplify( subs( pSAlpha, 'alpha', alphaM - eps ) );
    x2  = simplify( subs( pSAlpha, 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'P^T*sAlpha ist %s\n', printSym( x1, x2 ) ) ];

    % die beiden Koeffizienten A (von p1) und B (von p3) bestimmen
    [ A, B ] = coeff( x1, p );
    % die beiden Koeffizienten C (von p1) und D (von p3) bestimmen
    [ C, D ] = coeff( x1, p );

    txt = [ txt, sprintf( 'P^T*sAlpha: Term vor p1 ist %s\n', printSym( A, C ) ) ];
    txt = [ txt, sprintf( 'P^T*sAlpha: Term vor p3  ist %s\n', printSym( B, D ) ) ];

    x1  = simplify( subs( mue0, 'alpha', alphaM - eps ) );
    x2  = simplify( subs( mue0, 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'mue0 ist %s\n', printSym( x1, x2 ) ) ];

    x1  = simplify( subs( x0( 1 ), 'alpha', alphaM - eps ) );
    x2  = simplify( subs( x0( 1 ), 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'x0( 1 ) ist %s\n', printSym( x1, x2 ) ) ];

    x1  = simplify( subs( x0( 2 ), 'alpha', alphaM - eps ) );
    x2  = simplify( subs( x0( 2 ), 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'x0( 2 ) ist %s\n', printSym( x1, x2 ) ) ];

    x1  = simplify( subs( x0( 3 ), 'alpha', alphaM - eps ) );
    x2  = simplify( subs( x0( 3 ), 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'x0( 3 ) ist %s\n', printSym( x1, x2 ) ) ];

    x1  = simplify( subs( y0( 1 ), 'alpha', alphaM - eps ) );
    x2  = simplify( subs( y0( 1 ), 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'y0( 1 ) ist %s\n', printSym( x1, x2 ) ) ];

    x1  = simplify( subs( y0( 2 ), 'alpha', alphaM - eps ) );
    x2  = simplify( subs( y0( 2 ), 'alpha', alphaM + eps ) );
    txt = [ txt, sprintf( 'y0( 2 ) ist %s\n', printSym( x1, x2 ) ) ];
end

function ret = printSym( x1, x2 )
    if( simplify( x1 - x2 ) == 0 )
        ret = sprintf( 'gerade!' );
    else
        if( simplify( x1 + x2 ) == 0 )
            ret = sprintf( 'ungerade!' );
        else
            ret = sprintf( 'asymmetrisch!' );
        end
    end
end

function [ a, b ] = coeff( x, p )
    % x als Koeffizienten des Vektors P ausdrücken 
    x = collect( x, p );

    % die beiden Koeffizienten a (von p1) und b (von p3) bestimmen
    x = coeffs( x, [ p( 1 ), p( 3 ) ] );
    a = x( 1 );
    b = x( 2 );
end