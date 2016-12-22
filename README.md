# AStartSearchForCocosLua
A星搜索 Lua实现
# 
基于cocosLua写的工具
# 
适用于所有lua项目
# 
  
<p>---------------------------                                                                 </p>
<p>-- f(n) = g(n) + h(n)                                                                       </p>
<p>-- h(n) = △x + △y                                                                           </p>
<p>-- g(n) = g(pre) + 1                                                                        </p>
<p>                                                                                            </p>
<p>--e.g.                                                                                      </p>
<p>------ local beginNode = {};                                                                </p>
<p>------ beginNode.x = 1;                                                                     </p>
<p>------ beginNode.y = 2;                                                                     </p>
<p>------ local endNode = {};                                                                  </p>
<p>------ endNode.x = 9;                                                                       </p>
<p>------ endNode.y = 13;                                                                      </p>
<p>------ local blockList = {};                                                                </p>
<p>------ local result = AStartSearch.calcPath(10, 20, beginNode , endNode, blockList)         </p>
<p>----                                                                                        </p>
<p>------ 需要近似匹配请加参数                                                                 </p>
<p>---------------------------                                                                 </p>
