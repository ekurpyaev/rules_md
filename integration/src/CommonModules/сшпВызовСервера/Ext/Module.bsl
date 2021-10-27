﻿
#Область ПрограммныйИнтерфейс

// Функция - Установить значение константы
//
// Параметры:
//  ИмяКонстанты - константа, значение которой необходимо установить.
//  ЗначениеКонстанты - устанавливаемое значение.
// 
// Возвращаемое значение:
//	Булево - Изменение константы выполнено
//
Функция УстановитьЗначениеКонстанты(ИмяКонстанты, ЗначениеКонстанты) Экспорт
	
	Возврат сшпРаботаСКонстантами.УстановитьЗначениеКонстанты(ИмяКонстанты, ЗначениеКонстанты);
	
КонецФункции	

// Функция - Получить значение константы
//
// Параметры:
//	ИмяКонстанты - имя константы, значение которой нужно получить.
//
// Возвращаемое значение:
//	Значение константы, определённой по имени.
//
Функция ПолучитьЗначениеКонстанты(ИмяКонстанты) Экспорт
	
	Возврат сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты(ИмяКонстанты);
	
КонецФункции	

// Функция - Получить сервер 1С
// 
// Возвращаемое значение:
//	Значение константы "сшпСервер1С".
//
Функция ПолучитьСервер1С() Экспорт
	
	Возврат сшпРаботаСКонстантами.ПолучитьСервер1С();
	
КонецФункции

//Процедура - установить соединение и зарегистрировать ошибку
//
//Параметры:
//	Сообщение - Строка - строка сообщения об ошибке
//
Процедура сшпPipeУстановитьСоединениеИЗарегистрироватьОшибку(Сообщение) Экспорт
	
	сшпPipe.УстановитьСоединениеИЗарегистрироватьОшибку(Сообщение)
	
КонецПроцедуры

//Процедура - установить соединение и зарегистрировать предупреждение
//
//Параметры:
//	Сообщение - строка - строка сообщения о предупреждении
//
Процедура сшпPipeУстановитьСоединениеИЗарегистрироватьПредупреждение(Сообщение) Экспорт
	
	сшпPipe. УстановитьСоединениеИЗарегистрироватьПредупреждение(Сообщение);

КонецПроцедуры

//Процедура - установить соединение и зарегистрировать информационное сообщение
//
//Параметры:
//	Сообщение - Строка - строка информационного сообщения
//
Процедура сшпPipeУстановитьСоединениеИЗарегистрироватьИнформационноеСообщение(Сообщение) Экспорт
	
	сшпPipe.УстановитьСоединениеИЗарегистрироватьИнформационноеСообщение(Сообщение);
	
КонецПроцедуры

//Процедура - установить соединение и зарегистрировать отладочное сообщение
//
//Параметры:
//	Сообщение - Строка - строка отладочного сообщения
//
Процедура сшпPipeУстановитьСоединениеИЗарегистрироватьОтладочноеСообщение(Сообщение) Экспорт
	
	сшпPipe.УстановитьСоединениеИЗарегистрироватьОтладочноеСообщение(Сообщение);
	
КонецПроцедуры

//Процедура - установить соединение и зарегистрировать ошибку
//
//Параметры:
//	Сообщение - Строка - строка сообщения об ошибке
//
Процедура сшпTcpУстановитьСоединениеИЗарегистрироватьОшибку(Сообщение) Экспорт
	
	сшпTcp.УстановитьСоединениеИЗарегистрироватьОшибку(Сообщение);
	
КонецПроцедуры

//Процедура - установить соединение и зарегистрировать предупреждение
//
//Параметры:
//	Сообщение - Строка - строка сообщения о предупреждении
//
Процедура сшпTcpУстановитьСоединениеИЗарегистрироватьПредупреждение(Сообщение) Экспорт
	
	сшпTcp.УстановитьСоединениеИЗарегистрироватьПредупреждение(Сообщение);	
	
КонецПроцедуры                          

//Процедура - установить соединение и зарегистрировать информационное сообщение
//
//Параметры:
//	Сообщение - Строка - строка информационного сообщения
//
Процедура сшпTcpУстановитьСоединениеИЗарегистрироватьИнформационноеСообщение(Сообщение) Экспорт
	
	сшпTcp.УстановитьСоединениеИЗарегистрироватьИнформационноеСообщение(Сообщение);
	
КонецПроцедуры

//Процедура - установить соединение и зарегистрировать отладочное сообщение
//
//Параметры:
//	Сообщение - Строка - строка отладочного сообщения
//
Процедура сшпTcpУстановитьСоединениеИЗарегистрироватьОтладочноеСообщение(Сообщение) Экспорт
	
	сшпTcp.УстановитьСоединениеИЗарегистрироватьИнформационноеСообщение(Сообщение);
	
КонецПроцедуры

//Процедура - Запустить обработчкики 
//
Процедура сшпTcpЗапуститьОбработчики() Экспорт
	
	сшпTcp.ЗапуститьОбработчики();
	
КонецПроцедуры

//Процедура - Запустить обработчкики 
//
Процедура сшпPipeЗапуститьОбработчики() Экспорт
	
	сшпPipe.ЗапуститьОбработчики();
	
КонецПроцедуры

//Процедура - Зарегистрировать ошибку 
//
Процедура ЗарегистрироватьОшибку(ТекстСообщения) Экспорт
	
	сшпВзаимодействиеСАдаптером.ЗарегистрироватьОшибку(ТекстСообщения);
	
КонецПроцедуры

//Процедура - Зарегистрировать предупреждение 
//
Процедура ЗарегистрироватьПредупреждение(ТекстСообщения) Экспорт
	
	сшпВзаимодействиеСАдаптером.ЗарегистрироватьПредупреждение(ТекстСообщения);
	
КонецПроцедуры

//Процедура - Зарегистрировать информационное сообщение 
//
Процедура ЗарегистрироватьИнформационноеСообщение(ТекстСообщения) Экспорт
	
	сшпВзаимодействиеСАдаптером.ЗарегистрироватьИнформационноеСообщение(ТекстСообщения);
	
КонецПроцедуры

//Процедура - Зарегистрировать отладочное сообщение 
//
Процедура ЗарегистрироватьОтладочноеСообщение(ТекстСообщения) Экспорт
	
	сшпВзаимодействиеСАдаптером.ЗарегистрироватьОтладочноеСообщение(ТекстСообщения);
	
КонецПроцедуры

// Процедура - Отправить сообщение об ошибке
//
// Параметры:
//  Класс - Строка - тип класса ошибки. 
//  Описание - Строка - описание ошибки. 
//  Свойства - Структура - дополнительные свойства ошибки. 
//
Процедура ОтправитьСообщениеОбОшибке(Класс, Описание, Свойства) Экспорт
	
	сшпСистемныеСообщения.ОтправитьСообщениеОбОшибке(Класс, Описание, Свойства);
	
КонецПроцедуры	

#КонецОбласти