local P7DB = {}
local Queries = {}

function P7DB.createCommand(queryname, query)
    if not Queries[queryname] then 
        Queries[queryname] = query
    else 
        print('VRP_DB_DRIVER: Error query already exists.')
    end 
end

function P7DB.execute(queryname, variables)
    if Queries[queryname] then 
        if variables then 
            exports['ghmattimysql']:execute(Queries[queryname], variables)
        else 
            exports['ghmattimysql']:execute(Queries[queryname])
        end 
    else 
        print('VRP_DB_DRIVER: Error query does not exist!')
    end 
end

function P7DB.asyncQuery(queryname, variables)
    if Queries[queryname] then 
        if variables then 
            local rows = exports['ghmattimysql']:executeSync(Queries[queryname], variables)
            return rows
        end 
    else 
        print('VRP_DB_DRIVER: Error query does not exist!')
        cb({{}, nil})
    end 
end

function P7DB.query(queryname, variables, cb)
    if Queries[queryname] then 
        if variables then 
            exports['ghmattimysql']:execute(Queries[queryname], variables, function(rows, affected)
                if cb then 
                    cb(rows, affected)
                end 
            end)
        end 
    else 
        print('VRP_DB_DRIVER: Error query does not exist!')
        cb({{}, nil})
    end 
end

function P7DB.SingleQuery(query)
    exports['ghmattimysql']:execute(query)
end

return P7DB