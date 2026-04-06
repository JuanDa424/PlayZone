# PlayZone

PlayZone es una plataforma web y móvil orientada a la reserva y pago de canchas sintéticas en tiempo real, diseñada para optimizar la gestión de usuarios y administradores, mejorando la eficiencia operativa y la experiencia del servicio.

## Problema

En el sector de alquiler de canchas deportivas, las reservas suelen gestionarse mediante llamadas telefónicas o mensajes informales, lo que genera errores, duplicidad de reservas, falta de trazabilidad y una experiencia deficiente para el usuario.

## Solución

PlayZone digitaliza el proceso de reservas mediante una aplicación que permite consultar disponibilidad, realizar reservas en tiempo real y gestionar pagos en línea, garantizando mayor control, eficiencia y confiabilidad en la operación.

## Tecnologías utilizadas

* Flutter para el desarrollo de la aplicación móvil multiplataforma
* Java con Spring Boot para el desarrollo del backend
* PostgreSQL como sistema de gestión de base de datos
* Hostinger para el despliegue del frontend
* Railway para el despliegue del backend
* Integración con Mercado Pago para procesamiento de pagos
* Google Maps API para servicios de geolocalización

## Arquitectura del sistema

El sistema se basa en una arquitectura cliente-servidor con comunicación mediante APIs RESTful.

* Cliente: Aplicación móvil desarrollada en Flutter
* Servidor: Backend en Java con Spring Boot
* Base de datos: PostgreSQL
* Servicios externos: Integración con pasarela de pagos y servicios de geolocalización

## Funcionalidades principales

* Registro e inicio de sesión de usuarios
* Búsqueda de canchas por ubicación geográfica
* Visualización de disponibilidad en tiempo real
* Reserva de canchas deportivas
* Procesamiento de pagos en línea
* Panel de administración para gestión de canchas y reservas

## Ejecución del proyecto

### Backend

1. Clonar el repositorio
2. Configurar el entorno de ejecución en Java
3. Ejecutar la aplicación mediante Spring Boot

### Aplicación móvil

1. Instalar Flutter en el entorno de desarrollo

2. Ejecutar el comando:

   flutter pub get

3. Iniciar la aplicación con:

   flutter run

## Metodología de desarrollo

El proyecto se desarrolló utilizando un enfoque híbrido:

* SCRUM para la gestión ágil del desarrollo por iteraciones
* PMBOK como marco de referencia para la gestión del proyecto (alcance, tiempo, costo y calidad)

## Equipo de desarrollo

* Juan David Garzón Lozano
* Juan David Castro García

## Estado del proyecto

MVP funcional en desarrollo, con implementación de las principales funcionalidades de reserva, pago y gestión de usuarios.
