function SonnenkompassPlot()
    clc
    clear

    format long

    ort    = 'LasPalmas';
    datum  = '12.10.2021';

    switch( ort )
        case 'LasPalmas'
            switch datum
                case '12.04.2021'
                    arrowType  = '\downarrow';
                    yArrow     = 1.3;
                    yUhrZeit   = 1.4;
                    squareSize = 2;

                case '12.10.2021'   % mein Besuch bei Waldemar
                    arrowType  = '\downarrow';
                    yArrow     = 1.3;
                    yUhrZeit   = 1.4;
                    squareSize = 2;

                case '21.06.2021'   % SSW
                    arrowType  = '\downarrow';
                    yArrow     = 3.0;
                    yUhrZeit   = 3.35;
                    squareSize = 6;

                case '30.06.2021'
                    arrowType  = '\downarrow';
                    yArrow     = 3.0;
                    yUhrZeit   = 3.35;
                    squareSize = 6;

                case '21.12.2021'   % WSW
                    arrowType  = '\downarrow';
                    yArrow     = 3.5;
                    yUhrZeit   = 4.0;
                    squareSize = 6;

                case '21.03.2021'   % Frühlings-Äquinoktikum 
                    arrowType  = '\downarrow';
                    yArrow     = 1.7;
                    yUhrZeit   = 2.0;
                    squareSize = 6;

                case '21.09.2021'   % Herbst-Äquinoktikum
                    arrowType  = '\downarrow';
                    yArrow     = 1.4;
                    yUhrZeit   = 1.7;
                    squareSize = 6;
            end
    end

    % Ergebnisdaten laden, Trajektorien (x: 3-dim, y: 2-dim)
    load( [ ort, '-', datum, '.mat' ], 'rE', 'x', 'y' )

    % Least-Squares für a,b,c
    [ a, b, c ] = lsq( x, rE );

    % Minimaler Abstand Stab <-> Schattenende und sein Index bestimmen,
    % minNdx ist Index des astronomischen Mittags (AM). 
    [ ~, minNdx ] = min( abs( y( :, 1 ) ) );
    minDistance   = y( minNdx, 2 );

    figure
    title( 'Schattentrajektorie' )
    hold( 'on' )
    box( 'on' )
    grid( 'on' )
    axis( 'equal' )
    xlabel( 'West-Ost [m]' )
    ylabel( 'Süd-Nord [m]' )

    % Darstellungsbereich in Metern
    xlim( squareSize * [ -1,   1 ] );
    ylim( squareSize * [ -0.1, 1 ] );

    % Ort des Stabes plotten
    plot( 0, 0, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r' )

    % Schatten-Trajektorie plotten (mittig zum AM)
    N = size( y, 1 );
    plot( y( minNdx : -1 : 1, 1 ), y( minNdx : -1 : 1, 2 ), '-o', ...
         'MarkerSize', 3, 'MarkerIndices', 1 : 10 : minNdx, ...
         'Color', 'k', 'LineWidth', 1 )
    plot( y( minNdx : N, 1 ), y( minNdx : N, 2 ), '-o', 'MarkerSize', 3, ...
         'MarkerIndices', 11 : 10 : minNdx, 'Color', 'k', 'LineWidth', 1 )

    % Markierung AM
    text( 0, yArrow, arrowType, 'HorizontalAlignment', 'center' )
    text( 0, yUhrZeit, 'astronomischer Mittag', 'HorizontalAlignment', ...
          'center' )

    legend( 'Stabposition', 'Trajektorie, 10 Minuten-Intervalle' )

    sprintf( 'Minimum des Abstandes zum Stab: %1.2f Meter', minDistance )
end