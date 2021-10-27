﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено( Параметры.Ключ ) Тогда
		
		ДанныеПакета = ПрочитатьПакет( Параметры.Ключ );
		
	КонецЕсли;	
	
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ПрочитатьПакет( Ключ )
	
	Запись = РегистрыСведений.грИсточникиДозапросов.СоздатьМенеджерЗаписи();
	ЗаполнитьЗначенияСвойств( Запись, Ключ );
	Запись.Прочитать();
	Если Запись.Выбран() Тогда
		Возврат Запись.ПакетXDTO.Получить();
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

#КонецОбласти