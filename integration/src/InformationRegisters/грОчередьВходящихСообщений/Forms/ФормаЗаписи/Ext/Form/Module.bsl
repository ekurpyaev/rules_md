﻿
#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СтатусПриИзменении(Элемент)
	ДатаИзменения = ПолучитьДатуСеанса();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ЗначениеЗаполнено(Запись.ИдентификаторСообщения) тогда
		текЗапрос = Новый Запрос("ВЫБРАТЬ
		                         |	тбСостояние.СтатусСообщения,
		                         |	тбСостояние.ДатаИзменения,
		                         |	тбОчередь.Хранилище
		                         |ИЗ
		                         |	РегистрСведений.грОчередьВходящихСообщений КАК тбОчередь
		                         |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.грСостояниеВходящихСообщений КАК тбСостояние
		                         |		ПО тбОчередь.ИдентификаторСообщения = тбСостояние.ИдентификаторСообщения
		                         |ГДЕ
		                         |	тбОчередь.ИдентификаторСообщения = &ИдентификаторСообщения");
								 текЗапрос.УстановитьПараметр("ИдентификаторСообщения", Запись.ИдентификаторСообщения);
								 текВыборка = текЗапрос.Выполнить().Выбрать();
								 текВыборка.Следующий();
				 
		//++ Градум, Фоминский А.С., Задача 22233 , 11.08.2021
		Если Запись.ФорматСообщения = Перечисления.сшпФорматыСообщений.XML Тогда 
			Сообщение = ОтформатироватьXMLСтроку(текВыборка.Хранилище.Получить());
		Иначе	
			Сообщение = текВыборка.Хранилище.Получить();
		КонецЕсли;	
		//-- Градум, Фоминский А.С., Задача 22233 , 11.08.2021
		Статус = текВыборка.СтатусСообщения;
		ДатаИзменения = текВыборка.ДатаИзменения;
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	грОбработкаПакетовИнтеграции.УстановитьСостояниеСообщения(Запись.ИдентификаторСообщения, Статус);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ПолучитьДатуСеанса()
	Возврат  ТекущаяДатаСеанса();
КонецФункции	


//++ Градум, Фоминский А.С., Задача 22233 , 11.08.2021
&НаСервереБезКонтекста
Функция ОтформатироватьXMLСтроку(СтрокаСообщения)
	
	// Заменяем escape - символы на нормальные
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&gt;&lt;", ">" + Символы.ПС + "<");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&amp;", "&");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&lt;", "<");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&gt;", ">");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&apos;", "'");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&quot;", """");
	
	// Излекаем сообщение из Body
	НачНомер        = Найти(СтрокаСообщения, "<Body>");
	XMLбезБоди      = Сред(СтрокаСообщения, НачНомер+6, Найти(СтрокаСообщения, "</Body>")-НачНомер-6);
	
	xdtoДокумент    = сшпОбщегоНазначения.ПолучитьОбъектXDTO(Константы.сшпФорматСообщений.Получить(), XMLбезБоди);
	
	// Создание объекта ЗаписьXML
	ЗаписьXML = Новый ЗаписьXML;
	// Указываем, что запись производится в строку, а не в файл
	ЗаписьXML.УстановитьСтроку();
	// При помощи объекта ФабрикаXDTO записываем данные пакета XDTO в запись XML
	ФабрикаXDTO.ЗаписатьXML(ЗаписьXML, xdtoДокумент, "ClassData" );
	// Получаем текст записи XML
	ТекстОбъектаXDTO = ЗаписьXML.Закрыть();
	
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, XMLбезБоди, ТекстОбъектаXDTO);
	
	Возврат СтрокаСообщения;
	
КонецФункции
//-- Градум, Фоминский А.С., Задача 22233 , 11.08.2021

#КонецОбласти