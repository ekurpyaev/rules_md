
#Область ПрограммныйИнтерфейс

// Функция - Push message
//
// Параметры:
//  message	 - ОбъектXDTO - объект-сообщение.
// 
// Возвращаемое значение:
// Булево  - признак успешного получения сообщения.
//
Функция PushMessage(message)
	Возврат сшпSOAPСервис.soapPushMessage(message);
КонецФункции

// Функция - Push array of message
//
// Параметры:
//  ArrayOfMessage	 -  МассивXDTO - массив объектов-сообщений.
// 
// Возвращаемое значение:
// Булево  - признак успешного получения сообщения.
//
Функция PushArrayOfMessage(ArrayOfMessage)
	Возврат сшпSOAPСервис.soapPushArrayOfMessage(ArrayOfMessage);
КонецФункции

Функция PushMessageBatch(Messages)
	Возврат сшпSOAPСервис.soapPushMessageBatch(Messages);
КонецФункции

#КонецОбласти