<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('title');
            $table->text('excerpt')->nullable();
            $table->longText('body');
            $table->foreignId('category_id')->constrained('categories')->cascadeOnDelete();
            $table->foreignId('author_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('author_name')->nullable(); // fallback if author user is deleted
            $table->string('image')->nullable(); // uploaded path OR gradient spec "#E63946|#FF7A1A"
            $table->boolean('featured')->default(false);
            $table->boolean('breaking')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->unsignedInteger('reading_time')->default(3);
            $table->json('tags')->nullable();
            $table->timestamps();

            $table->index(['published_at', 'category_id']);
            $table->index('breaking');
            $table->index('featured');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
