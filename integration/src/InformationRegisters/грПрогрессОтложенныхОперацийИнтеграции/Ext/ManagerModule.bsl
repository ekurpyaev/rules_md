﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ДобавитьЗапись(Параметры) Экспорт

	ПараметрыДобавления = Новый Структура;
	
	Если Параметры.Свойство("ФоновоеЗадание") Тогда
		
		ПараметрыДобавления.Вставить("Наименование"			, Параметры.ФоновоеЗадание.Наименование);
		ПараметрыДобавления.Вставить("Начало"				, Параметры.ФоновоеЗадание.Начало);
		ПараметрыДобавления.Вставить("Ключ"					, Строка(Параметры.ФоновоеЗадание.Ключ));
		ПараметрыДобавления.Вставить("ИдентификаторЗадания"	, Строка(Параметры.ФоновоеЗадание.УникальныйИдентификатор));
	
	КонецЕсли;
	
	Если Параметры.Свойство("ИдентификаторЗаданияРодитель") Тогда
		ПараметрыДобавления.Вставить("ИдентификаторЗаданияРодитель" , Строка(Параметры.ИдентификаторЗаданияРодитель));
	КонецЕсли;
	
	Если Параметры.Свойство("Уровень") Тогда
		ПараметрыДобавления.Вставить("Уровень" , Строка(Параметры.Уровень));
	КонецЕсли;
	
	МЗ = РегистрыСведений.грПрогрессОтложенныхОперацийИнтеграции.СоздатьМенеджерЗаписи();
	ЗаполнитьЗначенияСвойств(МЗ, ПараметрыДобавления);
	МЗ.Записать();

КонецПроцедуры

#КонецЕсли
