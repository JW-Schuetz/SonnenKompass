%#ok<*NASGU> 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'x0', 'y0', 'y0StrichNom', ...
          'y0StrichDenom', 'mue0' )

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

    % Auswertung des Zählers der Ableitung nach alpha
    childs = children( y0StrichNom );
    for n = 1 : length( childs )
        % Term c bestimmen
        if( verNewer )  % neuere MatLab-Versionen
            c = childs{ n };
        else            % ältere MatLab-Versionen
            c = childs( n );
        end

        % Term c von alpha abhängig?
        if( has( c, alpha ) )
            y0StrichNom = eval( subs( c, alpha, alphaM ) );
            % Ableitung zu gross? Fehlermeldung
            if( y0StrichNom > 1e-10 )
                error( 'ACHTUNG: Ableitung ungleich 0!' )
            end
        end
    end

% Test Symmetrie
%     eps = 0.05;
% 
%     txt = '';
% 
%     xHNminus = double( subs( x0, 'alpha', alphaM - eps )' );
%     xHNplus  = double( subs( x0, 'alpha', alphaM + eps )' );
%     txt      = printSymT( txt, xHNminus, xHNplus, length( xHNminus ) );
% 
%     % Zahlenwerte bis auf alpha substituieren
%     mue0 = subs( mue0 );
%     mHNminus = double( subs( mue0, 'alpha', alphaM - eps )' );
%     mHNplus  = double( subs( mue0, 'alpha', alphaM + eps ) );
%     printSymGP( txt, mHNminus, mHNplus )
% Test Symmetrie

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
    for i = 1 : TNum + 1
        t  = tStart + ( i - 1 );                % t in Minuten
        al = double( pi / ( 12 * 60 ) * t );    % zugehöriger Winkel

        xLoc = subs( x0, 'alpha', al )';        % in x0 alpha substituieren
        xLoc = double( xLoc );
        x( i,         : ) = [ xLoc( 1 ),  xLoc( 2 ), xLoc( 3 ) ]; % Trajektorie 3-dim
        x( N - i + 1, : ) = [ xLoc( 1 ), -xLoc( 2 ), xLoc( 3 ) ]; % Trajektorie 3-dim

        yLoc = subs( y0, 'alpha', al )';        % in y0 alpha substituieren
        yLoc = double( yLoc );
        y( i, 1 : 2 )         = [  yLoc( 1 ), yLoc( 2 ) ]; % Trajektorie 2-dim
        y( N - i + 1, 1 : 2 ) = [ -yLoc( 1 ), yLoc( 2 ) ]; % Trajektorie 2-dim
    end

    save( fileName, 'rE', 'x', 'y' )
end

function ret = printSymT( ret, minus, plus, N )
    for n = 1 : N
        txt = sprintf( 'Die x%d-Komponente der Trajektorie x0(alpha) ist', n );
        if( abs( minus( n ) - plus( n ) ) < 1e-12 )
            ret = [ ret, sprintf( '%s gerade!\n', txt ) ]; %#ok<AGROW>
        else
            if( abs( minus( n ) + plus( n ) ) < 1e-12 )
                ret = [ ret, sprintf( '%s ungerade!\n', txt ) ]; %#ok<AGROW>
            else
                error( 'Das sollte nicht passieren!' )
            end
        end
    end
end

function ret = printSymGP( ret, minus, plus )
    ret = [ ret, sprintf( '%s', 'Der Geradenparameter mue0(alpha) ist ' ) ];
    if( abs( minus - plus ) < 1e-12 )
        ret = [ ret, sprintf( ' gerade!\n' ) ];
    else
        if( abs( minus + plus ) < 1e-12 )
        ret = [ ret, sprintf( ' ungerade!\n' ) ];
        else
            error( 'Das sollte nicht passieren!' )
        end
    end
end
