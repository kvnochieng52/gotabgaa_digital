<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('videos', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('title');
            $table->text('description')->nullable();
            $table->foreignId('category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->string('duration', 12); // "45:12" or "1:12:30"
            $table->string('video_url')->nullable(); // YouTube/Vimeo/direct mp4 URL
            $table->string('image')->nullable();
            $table->timestamp('aired_at')->nullable();
            $table->unsignedBigInteger('views')->default(0);
            $table->boolean('published')->default(true);
            $table->timestamps();

            $table->index(['published', 'aired_at']);
            $table->index('category_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('videos');
    }
};
