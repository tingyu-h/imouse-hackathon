from twisted.internet.protocol import Protocol, Factory
from twisted.internet import reactor
from pymaCursor import*

screenWidth = 1365
screenHeight = 766
x = 700
y = 350
deltax = 0
deltay = 0
left = 0
right = 0


class IphoneChat(Protocol):
    def connectionMade(self):
        #self.transport.write("""connected""")
        self.factory.clients.append(self)
        print "clients are ", self.factory.clients
        
    def connectionLost(self, reason):
        self.factory.clients.remove(self)
    
    def dataProcess(self):
        global x, y, deltax, deltay, left, right
        
        if (left == 1):
            performLeftClick(0)
        else:
            if (right == 1):
                performRightClick()
            else:
                newx = x+deltax
                newy = y+deltay
                
                x = outOfRangeProcess(newx, screenWidth )
                y = outOfRangeProcess(newy, screenHeight )

                print "Move to: ", x,y

                stepMouseToPoint(x, y, 50)
        
    def dataReceived(self, data):
        global x, y, deltax, deltay, left, right
        print "data is ", data
        data = data[:-1]
        dataList = data.split(',')
        print "processed data is", dataList
        i        = 0
        
        while i < len(dataList) -1 :
            if (dataList[i] != ''):
                left  = int(dataList[i])
       
            if (dataList[i + 1] != ''):
                right = int(dataList[i + 1])

            if (dataList[i + 2] != ''):
                deltax = -int(dataList[i + 2])

            if (dataList[i + 3] != ''):
                deltay = -int(dataList[i + 3])
            
            if left == 1:
                print "Left click"
            
            if right == 1:
                print "Right click"
        
            self.dataProcess()
            
            deltax = 0
            deltay = 0
            left   = 0
            right  = 0

            i += 4

    def message(self, message):
        self.transport.write(message + '\n')


factory = Factory()
factory.protocol = IphoneChat
factory.clients = []

reactor.listenTCP(80, factory)
print "iMouse server started"
reactor.run()

