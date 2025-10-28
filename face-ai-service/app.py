from flask import Flask, request, jsonify
from deepface import DeepFace

app = Flask(__name__)

# Endpoint 1: Tạo vector (2D/3D -> Vector)
@app.route("/generate", methods=["POST"])
def generate():
    data = request.json
    image_base64 = data["image_base64"] # Giả sử nhận base64
    
    # Dùng DeepFace để tạo embedding (vector)
    # model_name='Facenet' là một lựa chọn phổ biến
    try:
        embedding = DeepFace.represent(img_path = image_base64, 
                                       model_name = 'Facenet', 
                                       enforce_detection = False)[0]["embedding"]
        
        # AI service trả về JSON chứa vector
        return jsonify({"embedding": str(embedding)}) # Chuyển list thành string
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Endpoint 2: So sánh (Vector vs Data)
@app.route("/verify", methods=["POST"])
def verify():
    data = request.json
    saved_embedding_str = data["embedding"] # Vector 2D (dạng string)
    live_image_base64 = data["image_base64"] # Dữ liệu 3D (dạng base64)
    
    # Chuyển string vector về list<float>
    import ast
    saved_embedding = ast.literal_eval(saved_embedding_str)
    
    try:
        # Dùng DeepFace để so sánh
        result = DeepFace.verify(img1_path = live_image_base64, 
                                 img2_path = saved_embedding, # DeepFace có thể so sánh ảnh với vector
                                 model_name = 'Facenet',
                                 enforce_detection = False)

        # AI service trả về JSON
        return jsonify({"is_match": bool(result["verified"]), "similarity": result["distance"]})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Endpoint 3: Tinh chỉnh (Refine) - (Giả lập)
@app.route("/refine", methods=["POST"])
def refine():
    # Logic tinh chỉnh vector rất phức tạp
    # Tạm thời, chúng ta chỉ tạo vector mới từ dữ liệu 3D
    data = request.json
    data_3d_base64 = data["data_base64_3d"]
    
    try:
        embedding = DeepFace.represent(img_path = data_3d_base64, 
                                       model_name = 'Facenet', 
                                       enforce_detection = False)[0]["embedding"]
        
        return jsonify({"embedding": str(embedding)})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)