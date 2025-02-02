﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ЗначениеЗаполнено(Запись.ИдентификаторСообщения) Тогда
		текЗапрос = Новый Запрос("ВЫБРАТЬ
		                         |	Состояние.СтатусСообщения,
		                         |	Состояние.ДатаИзменения,
		                         |	ОчередьСообщений.Хранилище
		                         |ИЗ
		                         |	РегистрСведений.воОчередьВходящихСообщений КАК ОчередьСообщений
		                         |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.воСостояниеВходящихСообщений КАК Состояние
		                         |		ПО ОчередьСообщений.ИдентификаторСообщения = Состояние.ИдентификаторСообщения
		                         |ГДЕ
		                         |	ОчередьСообщений.ИдентификаторСообщения = &ИдентификаторСообщения");
								 текЗапрос.УстановитьПараметр("ИдентификаторСообщения", Запись.ИдентификаторСообщения);
								 текВыборка = текЗапрос.Выполнить().Выбрать();
								 текВыборка.Следующий();
				 
		Если Запись.ФорматСообщения = Перечисления.воФорматыСообщений.XML Тогда 
			Сообщение = ОтформатироватьXMLСтроку(текВыборка.Хранилище.Получить());
		Иначе	
			Сообщение = текВыборка.Хранилище.Получить();
		КонецЕсли;	
		Статус = текВыборка.СтатусСообщения;
		ДатаИзменения = текВыборка.ДатаИзменения;
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	воВходящиеОчередиВызовСервера.УстановитьСостояниеСообщения(Запись.ИдентификаторСообщения, Статус);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СтатусПриИзменении(Элемент)
	ДатаИзменения = ПолучитьДатуСеанса();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ПолучитьДатуСеанса()
	Возврат  ТекущаяДатаСеанса();
КонецФункции	


&НаСервереБезКонтекста
Функция ОтформатироватьXMLСтроку(СтрокаСообщения)
	
	// Заменяем escape - символы на нормальные
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&gt;&lt;", ">" + Символы.ПС + "<");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&amp;", "&");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&lt;", "<");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&gt;", ">");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&apos;", "'");
	СтрокаСообщения = СтрЗаменить(СтрокаСообщения, "&quot;", """");
	
	// Извлекаем сообщение из Body
	НачНомер        = Найти(СтрокаСообщения, "<Body>");
	XMLбезБоди      = Сред(СтрокаСообщения, НачНомер+6, Найти(СтрокаСообщения, "</Body>")-НачНомер-6);
	
	xdtoДокумент    = воОбщегоНазначенияВызовСервера.ПолучитьОбъектXDTO(Константы.воФорматСообщений.Получить(), XMLбезБоди);
	
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

#КонецОбласти