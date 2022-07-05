function [ a, b, c ] = lsq( x, rE )
    b = rE * ones( size( x, 1 ), 1 );

    method = 1;

    switch method
        case 1
            % QR-Zerlegung, Fehler: 3.7253e-09
            [ q, r ] = qr( x );
        
            c = q' * b;
            x = r \ c;

        case 2
            % Least Squares, Fehler: 2.5053e-07
            [ x, flag ] = lsqr( x, b );

        case 3
            % SVD, Fehler: ?
            [ u, s, v ] = svd( x );
    end

    a = x( 1 );
    b = x( 2 );
    c = x( 3 );
end
