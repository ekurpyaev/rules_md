﻿#Область ОбработчикиКомандФормы

&НаСервере
Функция ПолучитьКлючЗаписи(СтрокаБыстрогоПоиска)
	
	Возврат сшпОбщегоНазначения.ПолучитьКлючЗаписиПоСтрокеПоиска("сшпОчередьОтправляемыхСообщений", СтрокаБыстрогоПоиска);	
	
КонецФункции

&НаКлиенте
Процедура БыстрыйПоиск(Команда)
	
	КлючЗаписи = ПолучитьКлючЗаписи(СтрокаБыстрогоПоиска);
	
	Если ТипЗнч(КлючЗаписи) = Тип("Строка") Тогда 
		
		ПоказатьОповещениеПользователя(КлючЗаписи);
	
	Иначе
		
		Элементы.Список.ТекущаяСтрока = КлючЗаписи;
	
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
