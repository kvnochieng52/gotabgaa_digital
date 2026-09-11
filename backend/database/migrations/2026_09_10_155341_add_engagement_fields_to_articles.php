<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->string('youtube_url')->nullable()->after('image');
            $table->boolean('is_short')->default(false)->after('youtube_url');
            $table->unsignedBigInteger('view_count')->default(0)->after('is_short');
            $table->unsignedInteger('like_count')->default(0)->after('view_count');
            $table->unsignedBigInteger('remote_id')->nullable()->unique()->after('id');
            $table->string('status', 20)->default('published')->after('breaking');

            $table->index('is_short');
        });
    }

    public function down(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->dropIndex(['is_short']);
            $table->dropUnique(['remote_id']);
            $table->dropColumn(['youtube_url', 'is_short', 'view_count', 'like_count', 'remote_id', 'status']);
        });
    }
};
