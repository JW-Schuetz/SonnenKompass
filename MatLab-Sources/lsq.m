function [ a, b, c ] = lsq( x, rE )
    N  = size( x, 1 );
    b  = rE * ones( N, 1 );
    xs = zeros( N, 3 );

    method = 1;

    switch method
        case 1
            % QR-Zerlegung, Fehler: 3.7253e-09
            [ q, r ] = qr( x );

            c = q' * b;
            z = r \ c;

        case 2
            % Least Squares, Fehler: 2.5053e-07
            [ z, flag ] = lsqr( x, b );

        case 3
            % SVD, Fehler: ?
            [ u, s, v ] = svd( x );
    end

    a = z( 1 );
    b = z( 2 );
    c = z( 3 );

    A = [ a^2,   a * b, a * c;
          a * b, b^2,   b * c;
          a * c, b * c, c^2 ];

    % Überprüfung
    maximum = 0;
    for n = 1 : length( x )
        xs( n, : ) = A * x( n, : )';

        delta = abs( a * xs( n, 1 ) + b * xs( n, 2 ) + c * xs( n, 3 ) - rE );
        if( delta > maximum )
            maximum = delta;
        end
    end
end
