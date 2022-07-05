%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassSymbolic
    clc
    clear

    omega  = sym( 'omega', 'real' );            % Jahreszeiteinfluss
    thetaG = sym( 'thetaG', 'real' );           % Geographische Breite des Stabes
    psi    = sym( 'psi', 'real' );              % Komplementwinkel Erd-Rotationsachse zur Ekliptik
    rS     = sym( 'rS', 'real' );               % Abstand Erde - Sonne
    rE     = sym( 'rE', 'real' );               % Erdradius
    lS     = sym( 'lS', 'real' );               % Stablänge
    e      = sym( 'e', [ 3, 1 ], 'real' );      % Einheitsvektor Rotationsachse
    alpha  = sym( 'alpha', 'real' );            % Erd-Rotationswinkel (2*pi/24h)
    dAlpha = sym( 'dAlpha', [ 3, 3 ], 'real' );	% Drehmatrix
    p      = sym( 'p', [ 3, 1 ], 'real' );      % Fusspunkt des Stabes auf der Erdoberfläche und Stabende
    s      = sym( 's', [ 3, 1 ], 'real' );      % Sonnenposition in Bezug zum Erdmittelpunkt

    % der Längengrad ist stets 0°
    p( 2 ) = 0;

    % Einheitsvektor Rotationsachse
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
    sAlpha      = dMinusAlpha * s;

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
    y0Strich = diff( y0, 'alpha' );

    save( 'SonnenkompassSymbolic.mat', 'alpha', 'x0', 'y0', 'y0Strich' )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = MapToPlane( x0, thetaG, psi )
    theta = thetaG - psi;

    % Punkt drehen um x2-Achse und den Winkel theta
    if( theta ~= 0 )
        [ x1, x2, x3 ] = rotateX2( theta, x0( 1 ), x0( 2 ), x0( 3 ) );
    end

    % Projizieren auf die Tangentialebene
    A = [ 0, 1, 0; 0, 0, 1 ];
    x = A * [ x1; x2; x3 ];

    y = [ x( 1 ); x( 2 ) ];
end

function [ x1, x2, x3 ] = rotateX2( theta, x1, x2, x3 )
    % Punkt drehen um x2-Achse und den Winkel theta
    c = cos( theta );
    s = sin( theta );

    D = [  c, 0, s;
           0, 1, 0;
          -s, 0, c ];

    x = D * [ x1; x2; x3 ];

    x1 = x( 1 );
    x2 = x( 2 );
    x3 = x( 3 );
end