
---------------------------
-- f(n) = g(n) + h(n)
-- h(n) = △x + △y
-- g(n) = g(pre) + 1

--e.g.
    -- local beginNode = {};
    -- beginNode.x = 1;
    -- beginNode.y = 2;
    -- local endNode = {};
    -- endNode.x = 9;
    -- endNode.y = 13;
    -- local blockList = {};
    -- local result = AStartSearch.calcPath(10, 20, beginNode , endNode, blockList)

    -- 需要近似匹配请加参数
---------------------------

if not AStartSearch then
    cc.exports.AStartSearch = {}

    local AStartNode = class("AStartNode");

    function AStartNode:ctor(x, y)
        self.x = x or 1;
        self.y = y or 1;
    end

    -- 计算已走路程
    function AStartNode:calcCost(preNode)
        if not preNode then
            self.g = 0
        else
            if preNode.x == self.x or preNode.y == self.y then
                self.g = preNode.g + 1
            else
                self.g = preNode.g + 1.5
            end
        end
    end

    -- 计算终点距离
    function AStartNode:calcDist(endNode)
        self.h = (self.x - endNode.x)*(self.x - endNode.x) + (self.y - endNode.y)*(self.y - endNode.y)
    end

    -- 计算该点权重
    function AStartNode:calcF()
        self.f = self.g * self.g + self.h;
    end

    --合并计算
    function AStartNode:calc(preNode, endNode)
        self:calcCost(preNode);
        self:calcDist(endNode);
        self:calcF();
    end

    local dirNum = 8
    local dirx = { 1, 0,-1, 0, 1,-1, 1,-1};
    local diry = { 0, 1, 0,-1, 1,-1,-1, 1};

    --优先队列插入
    local insertToPriorityQueue = function(node, priorityQ)
        local insertIndex = 1;
        for i,v in ipairs(priorityQ) do
            if (node.f < v.f ) then
                insertIndex = i;
                break;
            end
        end
        table.insert(priorityQ, insertIndex, node)
    end

    --标记不可走的节点
    local markBlockPoint = function(markMap, blockList)
        for _,v in pairs(blockList) do
            if not markMap[v.x] then
                markMap[v.x] = {};
            end
            markMap[v.x][v.y] = true;
        end
    end

    --标记节点
    local markPoint = function(node, markMap)
        local x = node.x;
        local y = node.y;
        if not markMap[x] then
            markMap[x] = {};
        end
        if markMap[x][y] then
            return false;
        else
            markMap[x][y] = true
            return true;
        end
    end


    --更新记录节点信息
    local updatePointMap = function(node, preNode, pointMap)
        if not pointMap[node.x] then
            pointMap[node.x] = {};
        end
        if not pointMap[node.x][node.y] then
            -- pointMap[node.x][node.y] = node;
            -- return true;
        else
            if pointMap[node.x][node.y].f > node.f then
                -- pointMap[node.x][node.y] = node;
                -- return true;    
            else
                return false;
            end
        end

        node.preX = preNode.x
        node.preY = preNode.y
        pointMap[node.x][node.y] = node;

        return true;    

    end

    --是否在区域范围内
    local insideArea = function(w, h, node)
        return (node.x > 0 and node.x <= w and node.y > 0 and node.y <= h)
    end

    --计算两点距离（平方）
    local calcDistOfPoints = function(node1, node2)
        return (node1.x-node2.x)*(node1.x-node2.x) + (node1.y-node2.y)*(node1.y-node2.y)
    end

    local updateFuzzyNode = function(node, endNode, fuzzyNode)
        local newDist = calcDistOfPoints(node, endNode);
        if newDist < fuzzyNode.dist then
            fuzzyNode.x = node.x;
            fuzzyNode.y = node.y;
            fuzzyNode.dist = newDist;
        end
    end

    function AStartSearch.calcPath(w, h, beginNode , endNode, blockList, isFuzzy)
        
        local result = {};
        
        --没有目标或者没有起始点
        if (not beginNode) or (not endNode) then
            return result;
        end

        --目标就在隔壁
        local straightDist = calcDistOfPoints(beginNode, endNode)
        if straightDist < 3 then
            table.insert(result, beginNode);
            table.insert(result, endNode);
            return result;
        end
        
        if not blockList then
            blockList = {};
        end

        local beginP    = AStartNode.new(beginNode.x, beginNode.y)
        local endP      = AStartNode.new(endNode.x, endNode.y)
        local fuzzyNode = {};
        fuzzyNode.x = beginP.x;
        fuzzyNode.y = beginP.y;
        fuzzyNode.dist = straightDist
        beginP:calc(nil, endP);

        local priorityQ = {};
        insertToPriorityQueue(beginP, priorityQ);

        local markMap = {};
        local pointMap = {};

        markBlockPoint(markMap, blockList);
        markPoint(beginP, markMap)

        while(#priorityQ > 0) do

            local node = priorityQ[#priorityQ];
            priorityQ[#priorityQ] = nil;

            print(node.x, node.y)

            if node.x == endP.x and node.y == endP.y then
                endP = node
                break;
            end

            for i=1,dirNum do
                local x = node.x + dirx[i];
                local y = node.y + diry[i];
                local newNode = AStartNode.new(x, y)
                if insideArea(w, h, newNode) then
                    newNode:calc(node, endP);
                    if markPoint(newNode, markMap) and updatePointMap(newNode, node, pointMap) then
                        if isFuzzy then
                            updateFuzzyNode(newNode, endP, fuzzyNode)
                        end
                        insertToPriorityQueue(newNode, priorityQ);
                    end
                end
            end

        end

        print("--------------path--------------")

        local node = endP

        --没有找到合适路径
        if not node.preX then
            if isFuzzy then
                node = pointMap[fuzzyNode.x][fuzzyNode.y]
            end
        end

        if node.preX then
            print(node.x, node.y)
            table.insert(result, {x = node.x, y = node.y});
        end
        while(node.preX) do
            print(node.preX, node.preY)
            table.insert(result, {x = node.preX, y = node.preY});
            -- print(node.x, node.y)
            if not pointMap[node.preX][node.preY] then
                break;
            end
            node = pointMap[node.preX][node.preY];
        end
        print("END")

        -- 图形化打印路径
        -- local strDist = {"→","↑","←","↓","↗","↙","↘","↖"};
        -- for y=h,1,-1 do
        --     local str = "";
        --     for x=1,w do
        --        local tmpStr = "·"
        --         if pointMap[x] and pointMap[x][y] then
        --             local preX = pointMap[x][y].preX
        --             local preY = pointMap[x][y].preY
        --             local bx = preX-x;
        --             local by = preY-y;
        --             for i=1,dirNum do
        --                 if bx == dirx[i] and by == diry[i] then
        --                     tmpStr = strDist[i]
        --                     break;
        --                 end
        --              end 
        --          end
        --          str = str .. tmpStr
        --     end
        --     print(str)
        -- end

        return result;

    end

end