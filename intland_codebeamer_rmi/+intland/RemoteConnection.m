classdef RemoteConnection < handle
    properties 
        url
        username
        password
    end
 
    methods
        function connection = RemoteConnection(url, username, password)
            if nargin > 0
               connection.url = url;
               connection.username = username;
               connection.password = password;
            end
        end

        function result = jsonOptions(connection)
            result = weboptions('Username', connection.username, ...
                                'Password', connection.password, ...
                                'CharacterEncoding', 'UTF-8', ...
                                'MediaType', 'application/json', ...
                                'ContentType', 'json');
        end
        
        function result = textOptions(connection)
            result = weboptions('Username', connection.username, ...
                                'Password', connection.password, ...
                                'CharacterEncoding', 'UTF-8', ...
                                'MediaType', 'text/plain', ...
                                'ContentType', 'text');
        end

        function persist(connection, group)
            setpref(group, 'connection', connection);
        end
    end

    methods (Static)
        function connection = preferred(group)
            connection = intland.RemoteConnection('http://localhost:8080/cb', 'bond', '007');
            connection = getpref(group, 'connection', connection);
        end
    end
end
