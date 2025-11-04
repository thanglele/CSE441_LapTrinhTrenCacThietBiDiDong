// Application/Services/FaceRecognitionService.cs
using MyTLUServer.Application.Interfaces;
using System.Net.Http;
using System.Net.Http.Json; // Cần cho .NET 5+ (System.Text.Json)
using System.Threading.Tasks;
// Hoặc dùng Newtonsoft.Json nếu bạn đang dùng nó
// using Newtonsoft.Json;
// using System.Text;

namespace MyTLUServer.Application.Services
{
    public class FaceRecognitionService : IFaceRecognitionService
    {
        private readonly HttpClient _httpClient;

        public FaceRecognitionService(HttpClient httpClient)
        {
            // HttpClient đã được cấu hình BaseUrl và DI vào đây
            _httpClient = httpClient;
        }

        /// <summary>
        /// Tạo embedding SƠ KHAI (từ ảnh 2D hoặc 3D)
        /// </summary>
        public async Task<string> GenerateEmbeddingAsync(string dataBase64)
        {
            var requestDto = new { image_base64 = dataBase64 };

            // Gửi request đến AI Service (ví dụ: POST http://localhost:5001/generate)
            var response = await _httpClient.PostAsJsonAsync("/generate", requestDto);
            response.EnsureSuccessStatusCode(); // Ném lỗi nếu AI service trả về 4xx/5xx

            var responseDto = await response.Content.ReadFromJsonAsync<EmbeddingResponse>();

            // Giả sử AI trả về vector dạng JSON string: "[0.1, 0.2, ...]"
            // và CSDL lưu dạng varchar(max)
            return responseDto?.Embedding ?? string.Empty;
        }

        /// <summary>
        /// So sánh 2 yếu tố (vector vs data live)
        /// </summary>
        public async Task<bool> VerifyFaceAsync(string savedEmbedding, string liveSelfieBase64)
        {
            var requestDto = new
            {
                embedding = savedEmbedding,
                image_base64 = liveSelfieBase64
            };

            // Gửi request đến AI Service (ví dụ: POST http://localhost:5001/verify)
            var response = await _httpClient.PostAsJsonAsync("/verify", requestDto);
            response.EnsureSuccessStatusCode();

            var responseDto = await response.Content.ReadFromJsonAsync<VerifyResponse>();

            // (Bạn có thể điều chỉnh logic này nếu cần % similarity)
            return responseDto?.IsMatch ?? false;
        }

        /// <summary>
        /// TINH CHỈNH: Lấy vector 2D cũ và dữ liệu 3D mới để tạo ra 1 vector CHUẨN
        /// </summary>
        public async Task<string> RefineEmbeddingAsync(string base2DEmbedding, string data3DBase64)
        {
            var requestDto = new
            {
                base_embedding_2d = base2DEmbedding,
                data_base64_3d = data3DBase64
            };

            // Gửi request đến AI Service (ví dụ: POST http://localhost:5001/refine)
            var response = await _httpClient.PostAsJsonAsync("/refine", requestDto);
            response.EnsureSuccessStatusCode();

            var responseDto = await response.Content.ReadFromJsonAsync<EmbeddingResponse>();

            // Trả về vector đã được tinh chỉnh
            return responseDto?.Embedding ?? string.Empty;
        }


        // --- DTOs nội bộ cho việc giao tiếp với AI Service ---
        // (Sử dụng System.Text.Json (mặc định .NET Core) hoặc Newtonsoft)

        private class EmbeddingResponse
        {
            // Tên thuộc tính phải khớp 100% với JSON AI service trả về
            // [JsonPropertyName("embedding")] // Dùng nếu dùng System.Text.Json
            // [JsonProperty("embedding")] // Dùng nếu dùng Newtonsoft
            public string Embedding { get; set; } = string.Empty;
        }

        private class VerifyResponse
        {
            // [JsonPropertyName("is_match")]
            public bool IsMatch { get; set; }

            // [JsonPropertyName("similarity")]
            public double Similarity { get; set; }
        }
    }
}