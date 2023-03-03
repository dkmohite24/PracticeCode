({
	listAction : function(component, event, helper) 
	{
		//change the image names,header,description etc as required
		var name=['Carousel1','Carousel2','Carousel3'];
		var header=['Card1','Card2','Card3'];
		var description=['Description1','Description2','Description3'];
		var AlternativeText=['Text1','Text2','Text3'];
		var ImageUrl=['https://www.salesforce.com','https://www.salesforce.com','https://www.salesforce.com'];
		var b=['1','2','3','4','5'];
		var list1=[];
		var a=name.length;
		for(var i=0;i<a;i++)
		{
			list1.push({image:$A.get('$Resource.'+name[i]),Header:header[i],Description:description[i],AlterText:AlternativeText[i],imgUrl:ImageUrl[i]}) ;
		}
		component.set("v.lstimg",list1);
	}
})