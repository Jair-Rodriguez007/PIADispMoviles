import cv2
import numpy as np
import os
import base64
from datetime import datetime
from flask import Flask, request, jsonify

app = Flask(__name__)

# Configuración para almacenar imágenes procesadas
processed_image_folder = "processed_images"
os.makedirs(processed_image_folder, exist_ok=True)

def process_image(image_path):
    print(f"Procesando la imagen en la ruta: {image_path}")
    
    # Cargar la imagen
    image = cv2.imread(image_path)
    if image is None:
        raise ValueError("No se pudo cargar la imagen.")
    
    print(f"Tamaño de la imagen cargada: {image.shape}")

    # Calcular el color promedio de toda la imagen
    avg_color = cv2.mean(image)[:3]
    print(f"Color promedio de la imagen: {avg_color}")

    # Definir la cantidad de cuadros en los que se dividirá la imagen
    cuadricula_filas = 75
    cuadricula_columnas = 75
    altura_cuadro = image.shape[0] // cuadricula_filas
    ancho_cuadro = image.shape[1] // cuadricula_columnas

    # Tolerancia para considerar si un cuadro es diferente
    tolerancia = 40  # Ajusta este valor según la sensibilidad deseada

    # Copia de la imagen para marcar los cuadros con diferencias significativas
    output = image.copy()

    # Analizar cada cuadro y calcular el color promedio
    for fila in range(cuadricula_filas):
        for columna in range(cuadricula_columnas):
            # Definir los límites del cuadro
            inicio_x = columna * ancho_cuadro
            inicio_y = fila * altura_cuadro
            fin_x = inicio_x + ancho_cuadro
            fin_y = inicio_y + altura_cuadro

            # Extraer el cuadro de la imagen
            cuadro = image[inicio_y:fin_y, inicio_x:fin_x]

            # Calcular el color promedio del cuadro
            avg_color_cuadro = cv2.mean(cuadro)[:3]

            # Calcular la diferencia en color con el promedio general
            diferencia = np.linalg.norm(np.array(avg_color) - np.array(avg_color_cuadro))

            # Si la diferencia excede la tolerancia, marcar el cuadro en rojo
            if diferencia > tolerancia:
                cv2.rectangle(output, (inicio_x, inicio_y), (fin_x, fin_y), (0, 0, 255), 2)
    
    # Guardar la imagen procesada
    processed_image_path = os.path.join(processed_image_folder, f"processed_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg")
    cv2.imwrite(processed_image_path, output)
    print(f"Imagen procesada guardada en: {processed_image_path}")

    # Convertir la imagen procesada a base64 para enviar a Flutter
    with open(processed_image_path, "rb") as image_file:
        processed_image_base64 = base64.b64encode(image_file.read()).decode("utf-8")

    return processed_image_base64

@app.route('/process_image', methods=['POST'])
def process_image_route():
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    image_file = request.files['image']
    image_path = os.path.join(processed_image_folder, image_file.filename)
    image_file.save(image_path)

    # Procesa la imagen
    try:
        processed_image_base64 = process_image(image_path)
        return jsonify({"processed_image": processed_image_base64})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)