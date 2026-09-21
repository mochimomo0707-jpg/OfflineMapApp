package com.mapoffline;

import static spark.Spark.*;
import com.google.gson.Gson;
import com.graphhopper.GHRequest;
import com.graphhopper.GHResponse;
import com.graphhopper.GraphHopper;
import com.graphhopper.ResponsePath;
import com.graphhopper.config.CHProfile;
import com.graphhopper.config.Profile;
import com.graphhopper.util.shapes.GHPoint;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class App {
    private static GraphHopper hopper;
    private static final Gson gson = new Gson();

    public static void main(String[] args) {
        // 1. Cổng lắng nghe của Server
        port(8080);

        // Cho phép Frontend gọi API cục bộ không bị chặn CORS
        enableCORS();

        // 2. Khởi tạo Engine xử lý bản đồ GraphHopper
        initGraphHopper();

        // 3. API tính toán đường đi: /route?fromLat=...&fromLon=...&toLat=...&toLon=...
        get("/route", (req, res) -> {
            res.type("application/json");

            try {
                double fromLat = Double.parseDouble(req.queryParams("fromLat"));
                double fromLon = Double.parseDouble(req.queryParams("fromLon"));
                double toLat = Double.parseDouble(req.queryParams("toLat"));
                double toLon = Double.parseDouble(req.queryParams("toLon"));

                GHRequest request = new GHRequest(fromLat, fromLon, toLat, toLon)
                        .setProfile("car");

                GHResponse response = hopper.route(request);

                if (response.hasErrors()) {
                    res.status(400);
                    return gson.toJson(Map.of("error", response.getErrors().get(0).getMessage()));
                }

                ResponsePath path = response.getBest();
                
                // Lấy danh sách tọa độ các điểm đi qua để vẽ lên bản đồ
                List<List<Double>> coordinates = new ArrayList<>();
                path.getPoints().forEach(p -> coordinates.add(List.of(p.getLat(), p.getLon())));

                Map<String, Object> result = new HashMap<>();
                result.put("distance_meters", path.getDistance());
                result.put("time_seconds", path.getTime() / 1000);
                result.put("coordinates", coordinates);

                return gson.toJson(result);
            } catch (Exception e) {
                res.status(500);
                return gson.toJson(Map.of("error", e.getMessage()));
            }
        });

        System.out.println(">>> Server bản đồ offline đang chạy tại: http://localhost:8080");
    }

    private static void initGraphHopper() {
        hopper = new GraphHopper();
        // Đường dẫn file dữ liệu bản đồ OSM offline (sẽ tải ở bước sau)
        hopper.setOSMFile("data/map.osm.pbf");
        // Thư mục lưu cache đồ thị đường sá
        hopper.setGraphHopperLocation("data/graph-cache");
            
        // Cấu hình hồ sơ di chuyển (ở đây là xe hơi)
        hopper.setProfiles(new Profile("car"));
        hopper.getCHPreparationHandler().setCHProfiles(new CHProfile("car"));

        System.out.println("Đang nạp dữ liệu bản đồ offline, vui lòng chờ...");
        hopper.importOrLoad();
        System.out.println("Nạp bản đồ thành công!");
    }

    private static void enableCORS() {
        options("/*", (request, response) -> {
            String accessControlRequestHeaders = request.headers("Access-Control-Request-Headers");
            if (accessControlRequestHeaders != null) {
                response.header("Access-Control-Allow-Headers", accessControlRequestHeaders);
            }
            String accessControlRequestMethod = request.headers("Access-Control-Request-Method");
            if (accessControlRequestMethod != null) {
                response.header("Access-Control-Allow-Methods", accessControlRequestMethod);
            }
            return "OK";
        });
        before((request, response) -> response.header("Access-Control-Allow-Origin", "*"));
    }
}