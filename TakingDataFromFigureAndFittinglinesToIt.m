D=get(gca,'Children'); %get the handle of the line object
XData=get(D,'XData'); %get the x data
YData=get(D,'YData');
XData
XData{1}
X1 = XData{1}
Y1 = YData{1}

Exempt = find(X1 < 1*10^-9 & X1>0.3*10^-9)
Xfit1 = X1(Exempt(1):Exempt(end))
Yfit1 = Y1(Exempt(1):Exempt(end))
p1 = polyfit(Xfit1,Yfit1,1)
Exempt2 = find(X1>1.5*10^-9 & X1<3*10^-9 )
Xfit2 = X1(Exempt2(1):Exempt2(end))
Yfit2 = Y1(Exempt2(1):Exempt2(end))
p2 = polyfit(Xfit2,Yfit2,1)
plot( X1, polyval(p1,X1),'k')
plot( X1, polyval(p2,X1),'k')
x_intersect = fzero(@(x) polyval(p1-p2,x),3);
y_intersect = polyval(p1,x_intersect);