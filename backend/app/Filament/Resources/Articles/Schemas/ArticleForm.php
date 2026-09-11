<?php

namespace App\Filament\Resources\Articles\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class ArticleForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Story')
                    ->columnSpanFull()
                    ->schema([
                        TextInput::make('title')
                            ->required()
                            ->maxLength(200)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn ($state, callable $set, ?string $old, $context) => $context === 'create' ? $set('slug', Str::slug((string) $state)) : null),

                        TextInput::make('slug')
                            ->required()
                            ->maxLength(220)
                            ->helperText('URL slug — auto-generated from title.'),

                        Textarea::make('excerpt')
                            ->rows(2)
                            ->maxLength(500)
                            ->helperText('Short summary shown on cards.')
                            ->columnSpanFull(),

                        RichEditor::make('body')
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Section::make('Media & meta')
                    ->columns(2)
                    ->schema([
                        FileUpload::make('image')
                            ->image()
                            ->imageEditor()
                            ->directory('articles')
                            ->helperText('Cover image. Leave blank to use gradient placeholder.'),

                        Select::make('category_id')
                            ->relationship('category', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),

                        TextInput::make('author_name')
                            ->maxLength(120)
                            ->helperText('Author byline shown on the article.'),

                        TagsInput::make('tags')
                            ->separator(',')
                            ->helperText('Comma-separated. Used for SEO and related articles.'),
                    ]),

                Section::make('Publishing')
                    ->columns(3)
                    ->schema([
                        Toggle::make('featured')
                            ->helperText('Show in top-story slots.'),
                        Toggle::make('breaking')
                            ->helperText('Include in the breaking-news ticker.'),
                        DateTimePicker::make('published_at')
                            ->default(now())
                            ->required(),
                    ]),
            ]);
    }
}
