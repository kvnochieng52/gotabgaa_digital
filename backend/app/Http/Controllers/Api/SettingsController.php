<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;

class SettingsController extends Controller
{
    public function public()
    {
        $all = Setting::allAsMap();

        return response()->json([
            'stream' => [
                'tvTitle' => $all['tv_title'] ?? 'Gotabgaa TV',
                'tvStreamUrl' => $all['tv_stream_url'] ?? null,
                'radioTitle' => $all['radio_title'] ?? 'Gotabgaa Radio',
                'radioFrequency' => $all['radio_frequency'] ?? null,
                'radioStreamUrl' => $all['radio_stream_url'] ?? null,
            ],
            'social' => [
                'facebook' => $all['social_facebook'] ?? null,
                'twitter' => $all['social_twitter'] ?? null,
                'instagram' => $all['social_instagram'] ?? null,
                'youtube' => $all['social_youtube'] ?? null,
                'whatsapp' => $all['social_whatsapp'] ?? null,
            ],
        ]);
    }
}
