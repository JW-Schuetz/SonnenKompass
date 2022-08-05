%#ok<*NASGU> 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'x0', 'y0', 'y0StrichNom', ...
          'y0StrichDenom' )

    % Variable Daten
    ort   = 'LasPalmas';
    datum = '12.10.2021';

    fileName = [ ort, '-', datum, '.mat' ];

    switch( ort )
        case 'LasPalmas'
            thetaG = 28.136746041614316 / 180.0 * pi;	% geographische Breite Las Palmas
    end

    % Fixe Daten
    TNum = 60 * 5;                   % Zeitraum der num. Auswertung [min]
    lS   = 1.5;                      % Stablänge [m]
    rE   = 6371000.8;                % mittlerer Erdradius [m] (GRS 80, WGS 84)
    rS   = 149597870700.0;           % AE, mittlerer Abstand Erde - Sonne [m]
    psi  = 23.44 / 180.0 * pi;       % Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]

    ssw    = datetime( '21.06.2021' );	% Datum SSW
    tag    = datetime( datum );
    T      = days( tag - ssw );         % Jahreszeit [Tage seit SSW]
    omega  = 2 * pi / 365 * T;          % Jahreszeitwinkel ab SSW
    theta  = pi / 2 - ( thetaG - psi );	% Polarwinkel in Kugelkoordinaten

    % Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, dabei 
    % Neigung der Erd-Rotationsachse psi berücksichtigen
    p1 = rE * sin( theta );         % x-Koordinate
    p2 = 0;                         % y-Koordinate
    p3 = rE * cos( theta );         % z-Koordinate

    % Zahlenwerte bis auf alpha substituieren
    x0 = subs( x0 );    % die dreidimensionale Trajektorie
    y0 = subs( y0 );    % die zweidimensionale Trajektorie

    % astronomischer Mittag [rad] und []
    alphaM = double( atan2( tan( omega ), cos( psi ) ) + pi );
    tM     = 60 * 12 * alphaM / pi;

    % MatLab-Version höher als 2020a?
    verNewer = ~isempty( find( version( '-release' ) > '2020a', 1 ) );

    % Auswertung des Zählers
    childs = children( y0StrichNom );
    for n = 1 : length( childs )
        % MatLab-Version
        if( verNewer )
            c = childs{ n };
        else
            c = childs( n );
        end

        if( has( c, alpha ) )
            % nur der von alpha abhängige Term
            y0StrichNom = eval( subs( c, alpha, alphaM ) );
            % Ableitung zu gross? Fehlermeldung
            if( y0StrichNom > 1e-10 )
                error( 'Ableitung ungleich 0!' )
            end
        end
    end

%     % Test
%     t    = subs( x0, 'alpha', alphaM - 0.01 )';
%     xHN1 = double( t );
%     t    = subs( x0, 'alpha', alphaM )';
%     xHN2 = double( t );
%     t    = subs( x0, 'alpha', alphaM + 0.01 )';
%     xHN3 = double( t );
%     % Test

%   Beispiel: TNum = 3
%   ==================
%	tHN-3 tHN-2 tHN-1 tHN tHN+1 tHN+2 tHN+3

    tStart = tM - TNum;	% Endzeitpunkt = AM - TNum Minuten
    tEnd   = tM + TNum;	% Endzeitpunkt = AM + TNum Minuten

    % Numerische Auswertung
    N = fix( 2 * TNum + 1 );	% Anzahl der Zeitpunkte
    x = zeros( N, 3 );          % Trajektorie 3-dim [m]
    y = zeros( N, 2 );          % Trajektorie 2-dim [m]

    % Position und Zeitpunkt berechnen
    % Rechenzeit halbieren durch Nutzung der Symmetrie, es gilt:
    %   x(i,1) =  x(end-i,1)
    %   x(i,2) = -x(end-i,2)
    %   x(i,3) =  x(end-i,3)
    % und
    %   y(i,1) = -y(end-1,1)
    %   y(i,2) =  y(end-1,2)

    for i = 1 : N
        t          = tStart + ( i - 1 );                % t in Minuten
        alpha( i ) = double( pi / ( 12 * 60 ) * t );    % zugehöriger Winkel

        t         = subs( x0, 'alpha', alpha( i ) )';   % in x0 alpha substituieren
        x( i, : ) = double( t );                        % Trajektorie 3-dim

        yLoc = subs( y0, 'alpha', alpha( i ) )';        % in y0 alpha substituieren
        yLoc = double( yLoc );

        y( i, 1 : 2 ) = [ yLoc( 1 ), yLoc( 2 ) ];       % Trajektorie 2-dim
    end

    save( fileName, 'rE', 'x', 'y' )
end